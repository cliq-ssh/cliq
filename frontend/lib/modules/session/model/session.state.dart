import 'package:cliq/modules/session/model/session.model.dart';

class const SessionState({
  /// A list of active session tabs, where each tab can contain multiple ShellSessions, e.g., for split view.
  required final List<ShellSession> sessions,
}) {
  const new initial() : this(sessions: const []);

  SessionState copyWith({List<ShellSession>? sessions}) {
    return SessionState(sessions: sessions ?? this.sessions);
  }
}
