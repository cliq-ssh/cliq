import 'package:cliq/shared/data/database.dart';

import 'package:cliq/shared/provider/abstract_entity.state.dart';

class LogEntityState extends AbstractEntityState<Log, LogEntityState> {
  const new({required super.entities});

  new initial() : super.initial();

  LogEntityState copyWith({List<Log>? entities}) {
    return LogEntityState(entities: entities ?? this.entities);
  }
}
