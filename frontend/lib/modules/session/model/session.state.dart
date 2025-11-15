import 'package:cliq/modules/session/model/session.model.dart';
import 'package:dartssh2/dartssh2.dart';

class SSHSessionState {
  final List<ShellSession> activeSessions;
  final int? selectedSessionId;

  SSHSessionState.initial() : activeSessions = [], selectedSessionId = null;

  const SSHSessionState({
    required this.activeSessions,
    required this.selectedSessionId,
  });

  SSHSessionState copyWith({
    List<ShellSession>? activeSessions,
    int? selectedSessionId,
    Map<int, ShellSessionConnectionState>? connectionStates,
    Map<int, SSHClient>? clients,
    Map<int, SSHSession>? sshSessions,
  }) {
    return SSHSessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
    );
  }
}
