import '../../../shared/provider/abstract_entity.state.dart';

class KeyEntityState extends AbstractEntityState<int, KeyEntityState> {
  const KeyEntityState({required super.entities});

  KeyEntityState.initial() : super.initial();

  KeyEntityState copyWith({List<int>? entities}) {
    return KeyEntityState(entities: entities ?? this.entities);
  }
}
