import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/shared/provider/abstract_entity.state.dart';

class ConnectionEntityState
    extends AbstractEntityState<ConnectionFull, ConnectionEntityState> {
  const new({required super.entities});

  new initial() : super.initial();

  ConnectionEntityState copyWith({List<ConnectionFull>? entities}) {
    return ConnectionEntityState(entities: entities ?? this.entities);
  }
}
