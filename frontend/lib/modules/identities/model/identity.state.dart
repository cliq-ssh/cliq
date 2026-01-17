import 'package:cliq/modules/identities/model/identity_full.model.dart';

import '../../../shared/provider/abstract_entity.state.dart';

class IdentityEntityState
    extends AbstractEntityState<IdentityFull, IdentityEntityState> {
  const IdentityEntityState({required super.entities});

  IdentityEntityState.initial() : super.initial();

  IdentityEntityState copyWith({List<IdentityFull>? entities}) {
    return IdentityEntityState(entities: entities ?? this.entities);
  }
}
