import 'dart:async';

import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/key.state.dart';
import 'key_service.provider.dart';

final keyIdProvider = NotifierProvider(KeyNotifier.new);

class KeyNotifier extends AbstractEntityNotifier<int, KeyEntityState> {
  @override
  KeyEntityState buildInitialState() => .initial();
  @override
  Stream<List<int>> get entityStream => ref.read(keyServiceProvider).watchAll();

  @override
  KeyEntityState buildStateFromEntities(List<int> entities) =>
      state.copyWith(entities: entities);
}
