import 'package:cliq_api/cliq_api.dart';

import 'cliq_entity_impl.dart';

class VaultImpl extends CliqEntityImpl implements Vault {
  @override
  final String configuration;
  @override
  final String version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  const VaultImpl(
    super.api, {
    required this.configuration,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });
}
