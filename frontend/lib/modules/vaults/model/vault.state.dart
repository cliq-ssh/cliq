import 'package:cliq/shared/data/database.dart';

import 'package:cliq/shared/provider/abstract_entity.state.dart';

class VaultEntityState extends AbstractEntityState<Vault, VaultEntityState> {
  const new({required super.entities});

  new initial() : super.initial();

  VaultEntityState copyWith({List<Vault>? entities}) {
    return VaultEntityState(entities: entities ?? this.entities);
  }
}
