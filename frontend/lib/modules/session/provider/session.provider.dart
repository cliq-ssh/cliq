import 'dart:convert';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/shared/ui/navigation_shell.dart';
import 'package:crypto/crypto.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v4.dart';

import '../../../shared/data/database.dart';
import '../model/session.model.dart';

final sessionProvider = NotifierProvider(ShellSessionNotifier.new);

class ShellSessionNotifier extends Notifier<SSHSessionState> {
  final UuidV4 uuid = UuidV4();

  @override
  SSHSessionState build() => SSHSessionState.initial();

  /// Creates a new session and navigates to the session branch.
  void createAndGo(NavigationShellState shellState, ConnectionFull connection) {
    final id = uuid.generate();

    final newSession = ShellSession.disconnected(
      id: id,
      connection: connection,
    );
    final updatedSessions = [...state.activeSessions, newSession];
    final pageIndexes = _generatePageIndex(updatedSessions);
    shellState.goToBranch(1);

    state = state.copyWith(
      activeSessions: updatedSessions,
      selectedSessionId: newSession.id,
      pageIndexes: pageIndexes,
    );
  }

  /// Sets the current session and navigates to the session branch if a session is selected,
  /// or to the default branch (dashboard) if no session is selected.
  void setSelectedSession(NavigationShellState shellState, String? sessionId) {
    shellState.goToBranch(sessionId == null ? 0 : 1);
    state = state.copyWith(selectedSessionId: sessionId ?? '');
  }

  /// Closes the session with the given [sessionId].
  /// If the closed session was the selected one, selects the last session in the list or navigates to the default branch if no sessions remain.
  void closeSession(NavigationShellState shellState, String sessionId) {
    final updatedSessions = state.activeSessions
        .where((s) => s.id != sessionId)
        .toList();
    final pageIndexes = _generatePageIndex(updatedSessions);
    String? newSelectedSessionId = state.selectedSessionId;

    // If the closed session was the selected one, update the selected session.
    if (state.selectedSessionId == sessionId) {
      if (updatedSessions.isNotEmpty) {
        newSelectedSessionId = updatedSessions.last.id;
      } else {
        newSelectedSessionId = null;
        shellState.goToBranch(0); // Go to default branch if no sessions left.
      }
    }

    state = state.copyWith(
      activeSessions: updatedSessions,
      selectedSessionId: newSelectedSessionId,
      pageIndexes: pageIndexes,
    );
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

  Future<SSHClient> createSSHClient(
    ShellSession session,
    ConnectionFull connection,
  ) async {
    final (password, keys) = CredentialService.collectAuthenticationMethods(
      await CliqDatabase.credentialService.findByIds(
        connection.identity?.credentialIds ?? connection.credentialIds,
      ),
    );

    final socket = await SSHSocket.connect(connection.address, connection.port);
    final sshClient = SSHClient(
      socket,
      username: connection.effectiveUsername,
      identities: keys,
      onVerifyHostKey: (algorithm, hostKey) async {
        if (session.skipHostKeyVerification) {
          return true;
        }

        // check db whether host is known
        final (knownHost, isKeyMatch) = await CliqDatabase.knownHostService
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
  }

  Future<SSHSession?> spawnShell(String sessionId, SSHClient sshClient) async {
    try {
      final sshSession = await sshClient.shell();
      await sshClient.authenticated;
      _modifySession(
        sessionId,
        (session) => session.copyWith(
          connectedAt: DateTime.now(),
          sshClient: sshClient,
          sshSession: sshSession,
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

  Future<void> acceptFingerprint(String sessionId, KnownHostError error) async {
    await (error.knownHost != null
        ? CliqDatabase.knownHostService.update(
            error.knownHost!.id.value,
            hostKey: error.hostKey,
            compareTo: error.knownHost,
          )
        : CliqDatabase.knownHostService.createKey(
            host: error.host,
            hostKey: error.hostKey,
          ));
  }

  void _modifySession(
    String sessionId,
    ShellSession Function(ShellSession) modify,
  ) {
    final updatedSessions = state.activeSessions.map((session) {
      if (session.id == sessionId) {
        return modify(session);
      }
      return session;
    }).toList();

    state = state.copyWith(activeSessions: updatedSessions);
  }

  Map<String, int> _generatePageIndex(List<ShellSession> sessions) {
    final Map<String, int> pageIndexes = {};
    for (var i = 0; i < sessions.length; i++) {
      pageIndexes[sessions[i].id] = i;
    }
    return pageIndexes;
  }
}
