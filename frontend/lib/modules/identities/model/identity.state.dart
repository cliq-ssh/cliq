import 'package:cliq/modules/identities/model/identity_full.model.dart';

import 'package:cliq/shared/provider/abstract_entity.state.dart';

class IdentityEntityState
    extends AbstractEntityState<IdentityFull, IdentityEntityState> {
  const new({required super.entities});

  new initial() : super.initial();

  IdentityEntityState copyWith({List<IdentityFull>? entities}) {
    return IdentityEntityState(entities: entities ?? this.entities);
  }
}
