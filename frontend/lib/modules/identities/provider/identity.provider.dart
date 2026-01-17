import 'dart:async';

import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../model/identity.state.dart';

final identityProvider = NotifierProvider(IdentityNotifier.new);

class IdentityNotifier
    extends AbstractEntityNotifier<IdentityFull, IdentityEntityState> {
  @override
  IdentityEntityState buildInitialState() => .initial();
  @override
  Stream<List<IdentityFull>> get entityStream =>
      CliqDatabase.identityService.watchAll();

  @override
  IdentityEntityState buildStateFromEntities(List<IdentityFull> entities) =>
      state.copyWith(entities: entities);
}
