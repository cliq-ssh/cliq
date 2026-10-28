import 'dart:async';
import 'dart:ui';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/credentials/data/credential.service.dart';
import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/worker/sftp_worker.dart';
import 'package:cliq/modules/session/worker/ssh_worker.dart';
import 'package:cliq/modules/session/worker/worker_core.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';
import 'package:cliq/modules/settings/provider/known_host_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cliq/shared/utils/build_metadata.dart';
import 'package:flterm/flterm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v4.dart';

final sessionProvider = NotifierProvider(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  static const UuidV4 uuid = UuidV4();

  @override
  SessionState build() => const SessionState.initial();

  static String getSshIdent() {
    return 'SSH-2.0-cliq_${BuildMetadata.version}';
  }

  /// Builds the plain-data params every worker connects with
  Future<SshConnectParams> connectParams(
    ShellSession session,
    ConnectionFull connection,
  ) async {
    final ids = await ref
        .read(credentialServiceProvider)
        .findByIds(
          connection.identity?.credentialIds ?? connection.credentialIds,
        );
    final (password, keys) =
        await CredentialService.collectAuthenticationMethods(ids);

    return SshConnectParams(
      host: connection.address,
      port: connection.port,
      username: connection.effectiveUsername!,
      password: password,
      keys: keys.map((k) => (k.toPem(), password)).toList(),
      skipHostKeyVerification: session.skipHostKeyVerification,
    );
  }

  Future<SshWorkerHandle?> connectSsh(
    ShellSession session,
    ConnectionFull connection,
    TerminalController terminal, {
    required VoidCallback onExit,
  }) async {
    final worker = SshWorkerHandle(terminal);
    if (!await _startWorker(worker, session, connection, onExit: onExit)) {
      return null;
    }

    _modifySession(
      session.id,
      (s) => s.copyWith(
        connectedAt: .now(),
        ssh: worker,
        terminalController: terminal,
      ),
    );
    return worker;
  }

  Future<SftpWorkerHandle?> connectSftp(
    ShellSession session,
    ConnectionFull connection,
  ) async {
    final worker = SftpWorkerHandle();
    if (!await _startWorker(worker, session, connection)) return null;

    _modifySession(
      session.id,
      (s) => s.copyWith(connectedAt: .now(), sftp: worker),
    );
    return worker;
  }

  /// Creates a new session and navigates to the session branch, where the tab is selected.
  void createAndGo(
    NavigationShellState shellState,
    ConnectionFull connection, {
    bool isSftp = false,
  }) {
    final newSession = ShellSession.disconnected(
      id: uuid.generate(),
      type: isSftp ? .sftp : .ssh,
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
        shellState.goToDashboardBranch(); // Go to dashboard branch if no sessions left.
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

  Future<void> acceptFingerprint(
    DbId vaultId,
    String sessionId,
    KnownHostError error,
  ) async {
    if (error.knownHost != null) {
      await ref
          .read(knownHostServiceProvider)
          .update(
            error.knownHost!.id.value,
            vaultId: vaultId,
            fingerprint: error.fingerprint,
            compareTo: error.knownHost,
          );
    }
    await ref
        .read(knownHostServiceProvider)
        .createKnownHost(
          vaultId: vaultId,
          host: error.host,
          fingerprint: error.fingerprint,
        );
  }

  void _close(String sessionId, [String? message]) {
    _modifySession(sessionId, (session) {
      session.dispose();
      return .disconnected(
        id: session.id,
        type: session.type,
        connection: session.connection,
        skipHostKeyVerification: session.skipHostKeyVerification,
      );
    });
  }

  Future<bool> _verifyHostKey(
    ShellSession session,
    ConnectionFull connection,
    HostKeyRequestEvent request,
  ) async {
    final (knownHost, isKeyMatch) = await ref
        .read(knownHostServiceProvider)
        .isHostKnown(connection.addressAndPort, request.fingerprint);

    if (knownHost != null && isKeyMatch) return true;

    _modifySession(
      session.id,
      (s) => s.copyWith(
        knownHostError: KnownHostError(
          host: connection.addressAndPort,
          algorithm: request.algorithm,
          fingerprint: request.fingerprint,
          knownHost: knownHost,
        ),
      ),
    );

    // fail for now, the user can accept the key and retry
    return false;
  }

  /// Returns true if the worker is connected and ready
  Future<bool> _startWorker(
    WorkerHandle worker,
    ShellSession session,
    ConnectionFull connection, {
    VoidCallback? onExit,
  }) async {
    final SshConnectParams params;
    try {
      params = await connectParams(session, connection);
    } catch (e) {
      _close(session.id, e.toString());
      return false;
    }

    final ok = await worker.start(
      params,
      onHostKey: (r) => _verifyHostKey(session, connection, r),
      // clean exit
      onClosed: (e) =>
          e == null && onExit != null ? onExit() : _close(session.id, e),
    );
    if (!ok) return false; // onClosed already reported the error

    // the session was closed or reset while we were connecting
    if (getSessionById(session.id) == null) {
      worker.dispose();
      return false;
    }
    return true;
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
    final List<SessionTab> newActiveTabs = [...state.activeTabs].map((tab) {
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
