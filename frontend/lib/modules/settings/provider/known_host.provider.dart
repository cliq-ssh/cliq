import 'dart:async';

import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../model/known_host.state.dart';
import 'known_host_service.provider.dart';

final knownHostProvider = NotifierProvider(KnownHostNotifier.new);

class KnownHostNotifier
    extends AbstractEntityNotifier<KnownHost, KnownHostEntityState> {
  @override
  KnownHostEntityState buildInitialState() => .initial();
  @override
  Stream<List<KnownHost>> get entityStream =>
      ref.read(knownHostServiceProvider).watchAll();

  @override
  KnownHostEntityState buildStateFromEntities(List<KnownHost> entities) =>
      state.copyWith(entities: entities);
}
