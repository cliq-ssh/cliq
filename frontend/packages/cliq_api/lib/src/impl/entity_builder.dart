import 'package:cliq_api/cliq_api.dart';

import 'cliq_client_impl.dart';
import 'entities/user_impl.dart';
import 'entities/vault_impl.dart';

class EntityBuilder {
  final CliqClientImpl api;

  const EntityBuilder(this.api);

  Vault buildVault(Map<String, dynamic> json) {
    return VaultImpl(
      api,
      configuration: json['configuration'],
      version: json['version'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  User buildUser(Map<String, dynamic> json) {
    return UserImpl(
      api,
      id: json['id'],
      email: json['email'],
      username: json['username'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
