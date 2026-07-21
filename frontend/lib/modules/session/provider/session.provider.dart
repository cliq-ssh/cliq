import 'dart:async';
import 'dart:io';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_pty_new/flutter_pty_new.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v4.dart';

import '../../credentials/provider/credential_service.provider.dart';
import '../../settings/model/known_host_error.model.dart';
import '../../settings/provider/known_host_service.provider.dart';
import '../model/session.model.dart';
import '../model/tab.model.dart';

final sessionProvider = NotifierProvider(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  final UuidV4 uuid = UuidV4();
  Map<String, String> _inheritedEnv() => .of(Platform.environment);

  @override
  SessionState build() => SessionState.initial();

  /// Creates a new session and navigates to the session branch, where the tab is selected.
  void createAndGo(
    NavigationShellState shellState,
    ConnectionFull connection,
    SessionType type,
  ) {
    print(
      'Creating new session for connection: ${connection.label}, type: $type',
    );
    final newSession = ShellSession.disconnected(
      id: uuid.generate(),
      type: type,
      connection: connection,
    );

    final tab = SessionTab.create(id: uuid.generate(), root: newSession);

    final newActiveTabs = [...state.activeTabs, tab];
    final newTabPageIndices = _generatePageIndices(newActiveTabs);
    shellState.goToSessionBranch();

    state = state.copyWith(
      activeTabs: newActiveTabs,
      selectedTabId: tab.id,
      tabPageIndices: newTabPageIndices,
    );
  }

  /// Selects the tab with the given [tabId].
  /// If [tabId] is not null, navigates to the session branch.
  void setSelectedAndMaybeGo(NavigationShellState shellState, String? tabId) {
    if (tabId != null) {
      shellState.goToSessionBranch();
    }
    state = state.copyWith(selectedTabId: tabId ?? '');
  }

  /// Closes the session with the given [tabId].
  /// If the closed session was the selected one, selects the last session in the list or navigates to the default branch if no sessions remain.
  void closeTabAndMaybeGo(
    NavigationShellState shellState,
    String tabId, {
    bool dispose = true,
  }) {
    final tab = state.activeTabs.firstWhere((s) => s.id == tabId);

    final newActiveTabs = state.activeTabs.where((s) => s.id != tabId).toList();
    final newTabPageIndices = _generatePageIndices(newActiveTabs);
    String? newSelectedTabId = state.selectedTabId;

    // If the closed tab was the selected one, update the selected tab to the last one in the list,
    // or go to the dashboard if no tabs remain.
    if (state.selectedTabId == tabId) {
      if (newActiveTabs.isNotEmpty) {
        newSelectedTabId = newActiveTabs.last.id;
      } else {
        newSelectedTabId = null;
        shellState
            .goToDashboardBranch(); // Go to dashboard branch if no sessions left.
      }
    }

    if (dispose) {
      // dispose tab resources
      tab.dispose();
    }

    state = state.copyWith(
      activeTabs: newActiveTabs,
      selectedTabId: newSelectedTabId,
      tabPageIndices: newTabPageIndices,
    );
  }

  Future<SftpFile?> readFileFromSession(
    String sessionId,
    String filePath,
  ) async {
    final session = getSessionById(sessionId);
    if (session == null || session.sftpClient == null) return null;
    return (await session.sftpClient!.open(filePath));
  }

  void closeSessionAndMaybeGo(
    NavigationShellState shellState,
    String sessionId, {
    bool dispose = true,
  }) {
    final tabId = findTabIdBySessionId(sessionId);
    if (tabId == null) {
      // This should never happen
      return;
    }

    final tab = state.activeTabs.firstWhere((s) => s.id == tabId);
    final allSessions = [...tab.sessions, tab.root];

    if (dispose) allSessions.firstWhere((s) => s.id == sessionId).dispose();

    final remaining = allSessions.where((s) => s.id != sessionId).toList();

    // if no sessions remain, close the whole tab
    if (remaining.isEmpty) {
      closeTabAndMaybeGo(shellState, tabId, dispose: false);
      return;
    }

    // otherwise promote first remaining as new root
    final newRoot = tab.root.id == sessionId ? remaining.first : tab.root;
    final newSessions = remaining.where((s) => s.id != newRoot.id).toList();

    final newTab = tab.copyWith(root: newRoot, sessions: newSessions);
    state = state.copyWith(
      activeTabs: state.activeTabs
          .map((t) => t.id == tabId ? newTab : t)
          .toList(),
    );
  }

  ShellSession findById(String sessionId) {
    for (final tab in state.activeTabs) {
      for (final session in [...tab.sessions, tab.root]) {
        if (session.id == sessionId) {
          return session;
        }
      }
    }
    throw Exception('Session with id $sessionId not found in any active tab.');
  }

  /// Resets the session to a disconnected state, disposing of any existing SSH resources.
  void resetSession(
    NavigationShellState shellState,
    String sessionId, {
    bool skipHostKeyVerification = false,
  }) {
    _modifySession(sessionId, (session) {
      session.dispose();
      return ShellSession.disconnected(
        id: session.id,
        type: session.type,
        connection: session.connection,
        skipHostKeyVerification: skipHostKeyVerification,
      );
    });
  }

  /// Merges a single session into an existing tab, closing the merged session and adding it to the
  /// tab's sessions list. This is used for drag-and-drop merging of sessions.
  void merge(
    NavigationShellState shellState,
    String tabId,
    ShellSession newSession,
  ) {
    closeSessionAndMaybeGo(shellState, newSession.id, dispose: false);

    final tab = state.activeTabs.firstWhere((s) => s.id == tabId);
    final newSessions = [...tab.sessions, newSession];

    final newTab = tab.copyWith(
      sessions: newSessions,
      customLabel: tab.customLabel,
    );
    final newActiveTabs = state.activeTabs.map((t) {
      if (t.id == tabId) return newTab;
      return t;
    }).toList();
    state = state.copyWith(activeTabs: newActiveTabs);
  }

  /// Renames the tab with [tabId] to [customLabel]. If [customLabel] is null or empty the custom label will be
  /// cleared and UI will fall back to the default connection label.
  void renameTab(String tabId, String? customLabel) {
    final newActiveTabs = state.activeTabs.map((t) {
      if (t.id != tabId) return t;
      return t.copyWith(customLabel: customLabel?.trim());
    }).toList();

    state = state.copyWith(activeTabs: newActiveTabs);
  }

  Future<SSHClient?> createSSHClient(
    ShellSession session,
    ConnectionFull connection,
  ) async {
    final (
      password,
      keys,
    ) = await CredentialService.collectAuthenticationMethods(
      await ref
          .read(credentialServiceProvider)
          .findByIds(
            connection.identity?.credentialIds ?? connection.credentialIds,
          ),
    );

    try {
      final socket =
          await SSHSocket.connect(
              connection.address,
              connection.port,
              timeout: .new(seconds: 10), // TODO:
            )
            ..done.then(
              (_) => _close(session.id),
              onError: (e) => _close(session.id, e.toString()),
            );

      final sshClient =
          SSHClient(
              socket,
              username: connection.effectiveUsername!,
              identities: keys,
              onVerifyHostKey: (algorithm, fingerprint) async {
                if (session.skipHostKeyVerification) {
                  return true;
                }

                // check db whether host is known
                final (knownHost, isKeyMatch) = await ref
                    .read(knownHostServiceProvider)
                    .isHostKnown(connection.addressAndPort, fingerprint);

                if (knownHost != null && isKeyMatch) return true;

                _modifySession(
                  session.id,
                  (session) => session.copyWith(
                    knownHostError: KnownHostError(
                      host: connection.addressAndPort,
                      algorithm: algorithm,
                      fingerprint: fingerprint,
                      knownHost: knownHost,
                    ),
                  ),
                );

                // fail the verification for now, try again if the user accepts
                return false;
              },
              onPasswordRequest: password != null ? () => password : null,
            )
            ..done.then(
              (_) => _close(session.id),
              onError: (e) => _close(session.id, e.toString()),
            );

      return sshClient;
    } catch (e) {
      _close(session.id, e.toString());
      return null;
    }
  }

  Future<SSHSession?> spawnSsh(
    String sessionId,
    SSHClient client,
    TerminalController controller,
  ) async {
    try {
      await client.authenticated.onError(
        (e, _) => _close(sessionId, e.toString()),
      );
      final sshSession = await client.shell(
        pty: SSHPtyConfig(
          width: controller.cols,
          height: controller.rows,
          pixelHeight: controller.height.toInt(),
          pixelWidth: controller.width.toInt(),
        ),
      );
      _modifySession(
        sessionId,
        (session) => session.copyWith(
          connectedAt: DateTime.now(),
          client: client,
          sshSession: sshSession,
          terminalController: controller,
        ),
      );
      return sshSession;
    } catch (e) {
      client.close();
      _close(sessionId, e.toString());
      return null;
    }
  }

  Future<SftpClient> spawnSftp(String sessionId, SSHClient client) async {
    try {
      await client.authenticated;
      final sftpClient = await client.sftp();
      _modifySession(
        sessionId,
        (session) => session.copyWith(
          connectedAt: DateTime.now(),
          client: client,
          sftpClient: sftpClient,
        ),
      );
      return sftpClient;
    } catch (e) {
      client.close();
      _close(sessionId, e.toString());
      rethrow;
    }
  }

  Future<Pty?> spawnLocal(
    String sessionId,
    TerminalController controller,
  ) async {
    try {
      final pty = Pty.start(
        _defaultShellForPlatform(),
        columns: controller.cols,
        rows: controller.rows,
        environment: {..._inheritedEnv(), 'TERM': 'xterm-256color'},
      );

      _modifySession(
        sessionId,
        (session) => session.copyWith(connectedAt: DateTime.now(), pty: pty),
      );
      return pty;
    } catch (e) {
      _close(sessionId, e.toString());
      return null;
    }
  }

  void setStreamListeners(
    String sessionId,
    StreamSubscription? stdoutSub,
    StreamSubscription? stderrSub,
  ) {
    _modifySession(
      sessionId,
      (session) => session.copyWith(stdoutSub: stdoutSub, stderrSub: stderrSub),
    );
  }

  Future<int> acceptFingerprint(
    int vaultId,
    String sessionId,
    KnownHostError error,
  ) {
    if (error.knownHost != null) {
      return ref
          .read(knownHostServiceProvider)
          .update(
            error.knownHost!.id.value,
            vaultId: vaultId,
            fingerprint: error.fingerprint,
            compareTo: error.knownHost,
          );
    }
    return ref
        .read(knownHostServiceProvider)
        .createKnownHost(
          vaultId: vaultId,
          host: error.host,
          fingerprint: error.fingerprint,
        );
  }

  void _close(String sessionId, [String? message]) {
    _modifySession(
      sessionId,
      (session) =>
          session.copyWith(connectionError: message ?? 'Connection closed'),
    );
  }

  void _modifySession(
    String sessionId,
    ShellSession Function(ShellSession) modify,
  ) {
    final tabId = findTabIdBySessionId(sessionId);
    if (tabId == null) {
      // This should never happen
      return;
    }

    // replace tab with modified session
    List<SessionTab> newActiveTabs = [...state.activeTabs].map((tab) {
      if (tab.id != tabId) return tab;

      // update session in sessions list
      final newSessions = tab.sessions.map((s) {
        if (s.id != sessionId) return s;
        return modify(s);
      }).toList();

      // update root session if it is the one being modified
      final newRoot = tab.root.id == sessionId ? modify(tab.root) : tab.root;
      return tab.copyWith(root: newRoot, sessions: newSessions);
    }).toList();

    state = state.copyWith(activeTabs: newActiveTabs);
  }

  /// Finds the [ShellSession] with the given [sessionId] across all tabs, or null if not found.
  ShellSession? getSessionById(String sessionId) {
    for (final tabs in state.activeTabs) {
      for (final session in [...tabs.sessions, tabs.root]) {
        if (session.id == sessionId) {
          return session;
        }
      }
    }
    return null;
  }

  /// Finds the tab ID that contains the session with the given [sessionId].
  String? findTabIdBySessionId(String sessionId) {
    for (final entry in state.activeTabs) {
      final tab = entry;
      for (final session in [...tab.sessions, tab.root]) {
        if (session.id == sessionId) {
          return tab.id;
        }
      }
    }
    return null;
  }

  Map<String, int> _generatePageIndices(List<SessionTab> tabs) {
    final Map<String, int> pageIndices = {};
    for (var i = 0; i < tabs.length; i++) {
      pageIndices[tabs[i].id] = i;
    }
    return pageIndices;
  }

  String _defaultShellForPlatform() {
    if (Platform.isMacOS) {
      // macOS default shell lives here regardless of PATH; respect the
      // user's actual configured shell when available, but always fall
      // back to an absolute path — never a bare command name, since PTY
      // spawn does not reliably do shell-style PATH search, and a
      // GUI-launched app's PATH may not match an interactive shell's.
      return Platform.environment['SHELL'] ?? '/bin/zsh';
    }

    if (Platform.isLinux) {
      return Platform.environment['SHELL'] ?? '/bin/bash';
    }

    if (Platform.isWindows) {
      // Full path to cmd.exe; ComSpec is the canonical Windows env var.
      return Platform.environment['ComSpec'] ?? r'C:\Windows\System32\cmd.exe';
    }

    return '/bin/sh';
  }
}
