import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:cliq/shared/provider/abstract_entity.state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';

final connectionProvider = NotifierProvider(ConnectionNotifier.new);

typedef ConnectionEntityState = AbstractEntityState<ConnectionFull>;

class ConnectionNotifier extends AbstractEntityNotifier<ConnectionFull, ConnectionEntityState> {
  @override
  ConnectionEntityState buildInitialState() => .initial();
  @override
  Stream<List<ConnectionFull>> get entityStream => CliqDatabase.connectionService.watchConnectionFullAll();

  ConnectionFull? findById(int id) {
    for (final connection in state.entities) {
      if (connection.id == id) {
        return connection;
      }
    }
    return null;
  }
}
