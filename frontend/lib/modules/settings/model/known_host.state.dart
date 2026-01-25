import '../../../shared/data/database.dart';
import '../../../shared/provider/abstract_entity.state.dart';

class KnownHostEntityState
    extends AbstractEntityState<KnownHost, KnownHostEntityState> {
  const KnownHostEntityState({required super.entities});

  KnownHostEntityState.initial() : super.initial();

  KnownHostEntityState copyWith({List<KnownHost>? entities}) {
    return KnownHostEntityState(entities: entities ?? this.entities);
  }
}
