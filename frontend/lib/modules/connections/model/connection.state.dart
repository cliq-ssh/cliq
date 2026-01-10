import '../../../shared/provider/abstract_entity.state.dart';
import 'connection_full.model.dart';

class ConnectionEntityState
    extends AbstractEntityState<ConnectionFull, ConnectionEntityState> {
  const ConnectionEntityState({required super.entities});

  ConnectionEntityState.initial() : super.initial();

  ConnectionEntityState copyWith({List<ConnectionFull>? entities}) {
    return ConnectionEntityState(entities: entities ?? this.entities);
  }
}
