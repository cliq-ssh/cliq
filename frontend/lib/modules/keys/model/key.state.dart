import '../../../shared/data/database.dart';
import '../../../shared/provider/abstract_entity.state.dart';

class KeyEntityState extends AbstractEntityState<DbId, KeyEntityState> {
  const KeyEntityState({required super.entities});

  KeyEntityState.initial() : super.initial();

  KeyEntityState copyWith({List<DbId>? entities}) {
    return KeyEntityState(entities: entities ?? this.entities);
  }
}
