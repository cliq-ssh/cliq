import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/shared/ui/navigation_shell.dart';
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
  void createAndGo(NavigationShellState shellState, Connection connection) {
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

  Future<SSHClient> createSSHClient(ConnectionFull connection) async {
    final Credential? cred = connection.effectiveCredential;

    List<SSHKeyPair> keyPairs = [];
    if (cred != null && cred.type == .key) {
      if (SSHKeyPair.isEncryptedPem(cred.data)) {
        if (cred.passphrase == null) {
          throw Exception('Key is encrypted but no passphrase provided');
        }
        keyPairs = [
          ...keyPairs,
          ...SSHKeyPair.fromPem(cred.data, cred.passphrase!),
        ];
      } else {
        keyPairs = [...keyPairs, ...SSHKeyPair.fromPem(cred.data)];
      }
    }

    final socket = await SSHSocket.connect(connection.address, connection.port);
    final sshClient = SSHClient(
      socket,
      username: connection.effectiveUsername,
      identities: keyPairs,
      onPasswordRequest: () {
        if (cred != null && cred.type == .password) {
          return cred.data;
        }
        return null;
      },
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
        (session) => ShellSession(
          id: session.id,
          connection: session.connection,
          connectionError: e.toString(),
        ),
      );
      return null;
    }
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
