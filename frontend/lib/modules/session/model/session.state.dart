import 'package:cliq/modules/session/model/session.model.dart';

class SSHSessionState {
  final List<ShellSession> activeSessions;
  final String? selectedSessionId;
  final Map<String, int> pageIndexes;

  SSHSessionState.initial()
    : activeSessions = [],
      selectedSessionId = null,
      pageIndexes = {};

  const SSHSessionState({
    required this.activeSessions,
    required this.selectedSessionId,
    this.pageIndexes = const {},
  });

  ShellSession? get selectedSession {
    if (selectedSessionId == null) {
      return null;
    }
    for (final session in activeSessions) {
      if (session.id == selectedSessionId) {
        return session;
      }
    }
    return null;
  }

  int? get selectedSessionPageIndex {
    if (selectedSessionId == null) {
      return null;
    }
    return pageIndexes[selectedSessionId!] ?? 0;
  }

  SSHSessionState copyWith({
    List<ShellSession>? activeSessions,
    String? selectedSessionId,
    Map<String, int>? pageIndexes,
  }) {
    return SSHSessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
      pageIndexes: pageIndexes ?? this.pageIndexes,
    );
  }
}
