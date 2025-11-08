import 'package:cliq/modules/session/model/session.model.dart';

class SSHSessionState {
  final List<SSHSession> activeSessions;
  final int? selectedSessionId;

  SSHSessionState.initial() : activeSessions = [], selectedSessionId = null;

  const SSHSessionState({
    required this.activeSessions,
    required this.selectedSessionId,
  });

  SSHSessionState copyWith({
    List<SSHSession>? activeSessions,
    int? selectedSessionId,
  }) {
    return SSHSessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
    );
  }
}
