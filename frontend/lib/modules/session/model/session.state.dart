import 'package:cliq/modules/session/model/session.model.dart';
import 'package:dartssh2/dartssh2.dart';

class SSHSessionState {
  final List<ShellSession> activeSessions;
  final int? selectedSessionId;
  final Map<int, ShellSessionConnectionState> connectionStates;
  final Map<int, SSHClient> clients;
  final Map<int, SSHSession> sshSessions;

  SSHSessionState.initial()
    : activeSessions = [],
      selectedSessionId = null,
      connectionStates = {},
      clients = {},
      sshSessions = {};

  const SSHSessionState({
    required this.activeSessions,
    required this.selectedSessionId,
    required this.connectionStates,
    required this.clients,
    required this.sshSessions,
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
      connectionStates: connectionStates ?? this.connectionStates,
      clients: clients ?? this.clients,
      sshSessions: sshSessions ?? this.sshSessions,
    );
  }
}
