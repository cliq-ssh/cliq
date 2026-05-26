import 'dart:async';
import 'dart:convert';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/shared/ui/navigation_shell.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:crypto/crypto.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v4.dart';

import '../../credentials/provider/credential_service.provider.dart';
import '../../settings/provider/known_host_service.provider.dart';
import '../model/session.model.dart';
import '../model/tab.model.dart';

final sessionProvider = NotifierProvider(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  final UuidV4 uuid = UuidV4();

  @override
  SessionState build() => SessionState.initial();

  /// Creates a new session and navigates to the session branch, where the tab is selected.
  void createAndGo(NavigationShellState shellState, ConnectionFull connection) {
    final newSession = ShellSession.disconnected(
      id: uuid.generate(),
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
    _modifySession(
      sessionId,
      (session) => ShellSession.disconnected(
        id: session.id,
        connection: session.connection,
        skipHostKeyVerification: skipHostKeyVerification,
      ),
    );
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
    final newTab = tab.copyWith(sessions: newSessions);
    final newActiveTabs = state.activeTabs.map((t) {
      if (t.id == tabId) return newTab;
      return t;
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
      final socket = await SSHSocket.connect(
        connection.address,
        connection.port,
      );
      final sshClient = SSHClient(
        socket,
        username: connection.effectiveUsername!,
        identities: keys,
        onVerifyHostKey: (algorithm, hostKey) async {
          if (session.skipHostKeyVerification) {
            return true;
          }

          // check db whether host is known
          final (knownHost, isKeyMatch) = await ref
              .read(knownHostServiceProvider)
              .isHostKnown(connection.addressAndPort, hostKey);

          if (knownHost != null && isKeyMatch) return true;

          final sha256Fingerprint =
              'SHA256:${base64.encode(sha256.convert(hostKey).bytes).replaceAll('=', '')}';

          _modifySession(
            session.id,
            (session) => session.copyWith(
              knownHostError: KnownHostError(
                host: connection.addressAndPort,
                hostKey: hostKey,
                algorithm: algorithm,
                sha256Fingerprint: sha256Fingerprint,
                knownHost: knownHost,
              ),
            ),
          );

          // fail the verification for now, try again if the user accepts
          return false;
        },
        onPasswordRequest: password != null ? () => password : null,
      );

      return sshClient;
    } catch (e) {
      _modifySession(
        session.id,
        (session) => session.copyWith(connectionError: e.toString()),
      );
      return null;
    }
  }

  Future<SSHSession?> spawnShell(
    String sessionId,
    SSHClient sshClient,
    TerminalController controller,
  ) async {
    try {
      final sshSession = await sshClient.shell();
      await sshClient.authenticated;
      _modifySession(
        sessionId,
        (session) => session.copyWith(
          connectedAt: DateTime.now(),
          sshClient: sshClient,
          sshSession: sshSession,
          terminalController: controller,
        ),
      );
      return sshSession;
    } catch (e) {
      sshClient.close();
      _modifySession(
        sessionId,
        (session) => session.copyWith(connectionError: e.toString()),
      );
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
            hostKey: error.hostKey,
            compareTo: error.knownHost,
          );
    }
    return ref
        .read(knownHostServiceProvider)
        .createKnownHost(
          vaultId: vaultId,
          host: error.host,
          hostKey: error.hostKey,
        );
  }

  void _modifySession(
    String sessionId,
    ShellSession Function(ShellSession) modify,
  ) {
    final tabId = findTabIdBySessionId(sessionId);
    if (tabId == null) {
      // This should never happen
      throw Exception(
        'Session with id $sessionId not found in any active tab.',
      );
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
}
