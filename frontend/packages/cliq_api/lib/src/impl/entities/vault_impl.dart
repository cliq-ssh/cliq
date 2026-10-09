import 'package:cliq_api/cliq_api.dart';

import 'cliq_entity_impl.dart';

class const VaultImpl(
  super.api, {
  @override required final String configuration,
  @override required final String version,
  @override required final DateTime createdAt,
  @override required final DateTime updatedAt,
}) extends CliqEntityImpl implements Vault;
