import 'package:cliq/modules/hosts/view/hosts_page.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/routing/router.extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/sqlite/database.dart';
import '../model/session.model.dart';
import '../view/session_page_wrapper.dart';

final sessionProvider = NotifierProvider(ShellSessionNotifier.new);

class ShellSessionNotifier extends Notifier<SSHSessionState> {
  int _nextSessionId = 0;

  @override
  SSHSessionState build() => SSHSessionState.initial();

  void createAndGo(BuildContext context, Connection connection) {
    context.goPath(SessionPageWrapper.pagePath.build());
    final newSession = ShellSession(
      id: _nextSessionId++,
      connection: connection,
      connectionState: ShellSessionConnectionState.connecting,
    );
    state = state.copyWith(
      activeSessions: [...state.activeSessions, newSession],
      selectedSessionId: newSession.id,
    );
  }

  void setSelectedSession(BuildContext context, int? sessionId) {
    context.goPath(
      (sessionId == null ? HostsPage.pagePath : SessionPageWrapper.pagePath)
          .build(),
    );
    state = SSHSessionState(
      activeSessions: state.activeSessions,
      selectedSessionId: sessionId,
    );
  }
}
