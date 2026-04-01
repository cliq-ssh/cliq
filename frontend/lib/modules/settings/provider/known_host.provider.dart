import 'dart:async';

import 'package:cliq/modules/settings/model/known_host_full.model.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/known_host.state.dart';
import 'known_host_service.provider.dart';

final knownHostProvider = NotifierProvider(KnownHostNotifier.new);

class KnownHostNotifier
    extends AbstractEntityNotifier<KnownHostFull, KnownHostEntityState> {
  @override
  KnownHostEntityState buildInitialState() => .initial();
  @override
  Stream<List<KnownHostFull>> get entityStream =>
      ref.read(knownHostServiceProvider).watchAll();

  @override
  KnownHostEntityState buildStateFromEntities(List<KnownHostFull> entities) =>
      state.copyWith(entities: entities);
}
