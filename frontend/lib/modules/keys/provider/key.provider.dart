import 'dart:async';

import 'package:cliq/modules/keys/model/key.state.dart';
import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final keyIdProvider = NotifierProvider(KeyNotifier.new);

class KeyNotifier extends AbstractEntityNotifier<DbId, KeyEntityState> {
  @override
  KeyEntityState buildInitialState() => .initial();
  @override
  Stream<List<DbId>> get entityStream =>
      ref.read(keyServiceProvider).watchAll();

  @override
  KeyEntityState buildStateFromEntities(List<DbId> entities) =>
      state.copyWith(entities: entities);
}
