import 'package:cliq/modules/settings/model/known_host_full.model.dart';

import 'package:cliq/shared/provider/abstract_entity.state.dart';

class KnownHostEntityState
    extends AbstractEntityState<KnownHostFull, KnownHostEntityState> {
  const new({required super.entities});

  new initial() : super.initial();

  KnownHostEntityState copyWith({List<KnownHostFull>? entities}) {
    return KnownHostEntityState(entities: entities ?? this.entities);
  }
}
