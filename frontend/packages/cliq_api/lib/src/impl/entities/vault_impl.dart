import 'package:cliq_api/src/impl/entities/partial_vault_impl.dart';

import '../../../cliq_api.dart';

class VaultImpl(
  super.api, {
  @override required final String configuration,
  required super.id,
  required super.version,
  required super.createdAt,
  required super.updatedAt,
}) extends PartialVaultImpl implements Vault;
