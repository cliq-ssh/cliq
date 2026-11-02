import 'package:cliq_api/cliq_api.dart';

import 'cliq_entity_impl.dart';

class const PartialVaultImpl(
  super.api, {
  @override required final String id,
  @override required final String version,
  @override required final DateTime createdAt,
  @override required final DateTime updatedAt,
}) extends CliqEntityImpl implements PartialVault;
