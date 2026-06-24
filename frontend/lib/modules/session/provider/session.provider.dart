import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/modules/session/view/sftp_session_page.dart';
import 'package:cliq/shared/ui/navigation_shell.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:crypto/crypto.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v4.dart';

import '../../credentials/provider/credential_service.provider.dart';
import '../../settings/model/known_host_error.model.dart';
import '../../settings/provider/known_host_service.provider.dart';
import '../model/session.model.dart';
import '../model/sftp_transfer.model.dart';
import '../model/sftp_transfer_params.model.dart';
import '../model/tab.model.dart';

final sessionProvider = NotifierProvider(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  final UuidV4 uuid = UuidV4();

  @override
  SessionState build() => SessionState.initial();

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

  /// Transfers data from remote to local, local to remote or remote to remote via SFTP.
  /// This runs in a separate isolate to avoid overloading the main thread
  ///
  /// Returns a stream of progress values between 0.0 and 1.0, where 1.0 indicates completion.
  Stream<FileProgressData> transferSftp({
    ShellSession? source,
    ShellSession? destination,
    String? sourcePath,
    String? destinationPath,
    String? localPath,
  }) {
    assert(source != null || localPath != null);
    assert(destination != null || localPath != null);

    final controller = StreamController<FileProgressData>();

    resolveParams(ShellSession? session) async {
      if (session == null) return null;
      final conn = session.connection;
      final creds = await ref
          .read(credentialServiceProvider)
          .findByIds(conn.identity?.credentialIds ?? conn.credentialIds);
      final (password, keys) =
          await CredentialService.collectAuthenticationMethods(creds);

      // find hostKey for the source/destination host
      final hostKey = await ref
          .read(knownHostServiceProvider)
          .findKeyForHost(conn.addressAndPort);

      return SftpConnectParams(
        host: conn.address,
        port: conn.port,
        username: conn.effectiveUsername!,
        hostKey: hostKey!, // must exist since we're already connected
        password: password,
        keyPems: keys.map((k) => (k as dynamic).toPem() as String).toList(),
      );
    }

    Future<void> run() async {
      final port = ReceivePort();

      await Isolate.spawn(
        sftpTransferIsolate,
        SftpTransferParams(
          sendPort: port.sendPort,
          source: await resolveParams(source),
          sourcePath: sourcePath ?? localPath!,
          destination: await resolveParams(destination),
          destinationPath: destinationPath ?? localPath!,
        ),
      );

      await for (final msg in port) {
        final data = msg as FileProgressData;

        // should never happen
        if (data.error != null || data.progress < 0) {
          port.close();
          controller.addError(.new());
          break;
        }

        controller.add(data);

        if (data.progress >= 1.0) {
          port.close();
          break;
        }
      }
      await controller.close();
    }

    run().catchError(controller.addError);
    return controller.stream;
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
        type: session.type,
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

  Future<SSHSession?> spawnSsh(
    String sessionId,
    SSHClient client,
    TerminalController controller,
  ) async {
    try {
      final sshSession = await client.shell();
      await client.authenticated;
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
      _modifySession(
        sessionId,
        (session) => session.copyWith(connectionError: e.toString()),
      );
      return null;
    }
  }

  Future<SftpClient> spawnSftp(String sessionId, SSHClient client) async {
    try {
      final sftpClient = await client.sftp();
      await client.authenticated;
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
      _modifySession(
        sessionId,
        (session) => session.copyWith(connectionError: e.toString()),
      );
      rethrow;
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
