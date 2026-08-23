import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/provider/abstract_entity.state.dart';

class KeyEntityState extends AbstractEntityState<DbId, KeyEntityState> {
  const new({required super.entities});

  new initial() : super.initial();

  KeyEntityState copyWith({List<DbId>? entities}) {
    return KeyEntityState(entities: entities ?? this.entities);
  }
}
