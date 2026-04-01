import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/connection.state.dart';
import 'connection_service.provider.dart';

final connectionProvider = NotifierProvider(ConnectionNotifier.new);

class ConnectionNotifier
    extends AbstractEntityNotifier<ConnectionFull, ConnectionEntityState> {
  @override
  ConnectionEntityState buildInitialState() => .initial();
  @override
  Stream<List<ConnectionFull>> get entityStream =>
      ref.read(connectionServiceProvider).watchAll();

  ConnectionFull? findById(int id) {
    for (final connection in state.entities) {
      if (connection.id == id) {
        return connection;
      }
    }
    return null;
  }

  @override
  ConnectionEntityState buildStateFromEntities(List<ConnectionFull> entities) =>
      state.copyWith(entities: entities);
}
