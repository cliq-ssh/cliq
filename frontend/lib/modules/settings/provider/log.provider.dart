import 'dart:async';

import 'package:cliq/modules/settings/model/log.state.dart';
import 'package:cliq/modules/settings/provider/log_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final logProvider = NotifierProvider(LogNotifier.new);

class LogNotifier extends AbstractEntityNotifier<Log, LogEntityState> {
  @override
  LogEntityState buildInitialState() => .initial();
  @override
  Stream<List<Log>> get entityStream => ref.read(logServiceProvider).watchAll();

  @override
  LogEntityState buildStateFromEntities(List<Log> entities) =>
      state.copyWith(entities: entities);
}
