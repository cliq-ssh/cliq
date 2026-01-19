import 'dart:async';

import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../model/key.state.dart';

final identityProvider = NotifierProvider(IdentityNotifier.new);

class IdentityNotifier extends AbstractEntityNotifier<int, KeyEntityState> {
  @override
  KeyEntityState buildInitialState() => .initial();
  @override
  Stream<List<int>> get entityStream => CliqDatabase.keyService.watchAll();

  @override
  KeyEntityState buildStateFromEntities(List<int> entities) =>
      state.copyWith(entities: entities);
}
