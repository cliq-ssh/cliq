import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/routing/view/navigation_shell.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/sqlite/database.dart';
import '../model/session.model.dart';

final sessionProvider = NotifierProvider(ShellSessionNotifier.new);

class ShellSessionNotifier extends Notifier<SSHSessionState> {
  int _nextSessionId = 0;

  @override
  SSHSessionState build() => SSHSessionState.initial();

  /// Creates a new session and navigates to the session branch.
  void createAndGo(NavigationShellState shellState, Connection connection) {
    shellState.goToBranch(1);
    final newSession = ShellSession(
      id: _nextSessionId++,
      connection: connection,
      state: .connecting,
    );
    state = state.copyWith(
      activeSessions: [...state.activeSessions, newSession],
      selectedSessionId: newSession.id,
    );
  }

  /// Sets the current session and navigates to the session branch if a session is selected,
  /// or to the default branch (dashboard) if no session is selected.
  void setSelectedSession(NavigationShellState shellState, int? sessionId) {
    shellState.goToBranch(sessionId == null ? 0 : 1);
    state = SSHSessionState(
      activeSessions: state.activeSessions,
      selectedSessionId: sessionId,
    );
  }

  void setSessionState(int sessionId, ShellSessionConnectionState newState) {
    _modifySession(sessionId, (session) => session.copyWith(state: newState));
  }

  void setSessionSSHClient(int sessionId, SSHClient sshClient) {
    _modifySession(
      sessionId,
      (session) => session.copyWith(sshClient: sshClient),
    );
  }

  void setSessionSSHSession(int sessionId, SSHSession sshSession) {
    _modifySession(
      sessionId,
      (session) => session.copyWith(sshSession: sshSession),
    );
  }

  void _modifySession(
    int sessionId,
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
}
