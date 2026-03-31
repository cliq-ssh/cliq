import 'package:cliq/shared/data/database.dart';

import '../../../shared/provider/abstract_entity.state.dart';

class VaultEntityState extends AbstractEntityState<Vault, VaultEntityState> {
  const VaultEntityState({required super.entities});

  VaultEntityState.initial() : super.initial();

  VaultEntityState copyWith({List<Vault>? entities}) {
    return VaultEntityState(entities: entities ?? this.entities);
  }
}
