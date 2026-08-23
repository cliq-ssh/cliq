import 'dart:async';

import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/vaults/model/vault.state.dart';
import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:cliq_api/cliq_api.dart' show CliqClient;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final vaultProvider = NotifierProvider(VaultNotifier.new);

class VaultNotifier extends AbstractEntityNotifier<Vault, VaultEntityState> {
  @override
  VaultEntityState buildInitialState() => .initial();
  @override
  Stream<List<Vault>> get entityStream =>
      ref.read(vaultServiceProvider).watchAll();

  Vault? findById(DbId id) {
    for (final vault in state.entities) {
      if (vault.id == id) {
        return vault;
      }
    }
    return null;
  }

  /// Finds or creates the user's local vault called "Local Vault".
  Future<Vault> findOrCreateVault([String? byOwner]) async {
    await initialized;

    for (final vault in state.entities) {
      // "local vault" if owner is null. there can only ever exist one local vault
      if (vault.owner == byOwner) {
        return vault;
      }
    }

    // not found; create vault instead
    return await ref.read(vaultServiceProvider).createVault(owner: byOwner);
  }

  Future<Vault> findOrCreateUserVault(CliqClient api) =>
      findOrCreateVault(api.selfUser.username);

  /// Convenience method for retrieving the 'default' vault based on login state
  Future<Vault> retrieveDefaultVault() async {
    final api = ref.read(syncProvider).api;

    if (api != null) {
      return await findOrCreateVault(api.selfUser.username);
    }
    return await findOrCreateVault();
  }

  @override
  VaultEntityState buildStateFromEntities(List<Vault> entities) =>
      state.copyWith(entities: entities);
}
