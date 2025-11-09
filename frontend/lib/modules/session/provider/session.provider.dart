import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/routing/view/navigation_shell.dart';
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
    );
    state.connectionStates[newSession.id] =
        ShellSessionConnectionState.connecting;
    state = state.copyWith(
      activeSessions: [...state.activeSessions, newSession],
      selectedSessionId: newSession.id,
    );
  }

  void setSelectedSession(NavigationShellState shellState, int? sessionId) {
    shellState.goToBranch(sessionId == null ? 0 : 1);
    state = SSHSessionState(
      activeSessions: state.activeSessions,
      selectedSessionId: sessionId,
      connectionStates: state.connectionStates,
      clients: state.clients,
      sshSessions: state.sshSessions,
    );
  }
}
