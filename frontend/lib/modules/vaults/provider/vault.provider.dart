import 'dart:async';

import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:cliq_api/cliq_api.dart' show CliqClient;
import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../../settings/provider/sync.provider.dart';
import '../model/vault.state.dart';

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
  Future<Vault> findOrCreateLocalVault() async {
    await initialized;

    for (final vault in state.entities) {
      if (vault.isDefault) {
        return vault;
      }
    }

    // not found; create default vault
    return await ref
        .read(vaultServiceProvider)
        .createVault(label: 'local_vault'.tr(), isDefault: true);
  }

  /// Finds or creates the user's vault.
  Future<Vault> findOrCreateUserVault(CliqClient api) async {
    await initialized;

    for (final vault in state.entities) {
      if (vault.label == api.selfUser.email) {
        return vault;
      }
    }

    return await ref
        .read(vaultServiceProvider)
        .createVault(label: api.selfUser.email, isDefault: false);
  }

  /// Convenience method for retrieving the 'default' vault based on login state
  Future<Vault> retrieveDefaultVault() async {
    final api = ref.read(syncProvider).api;

    if (api != null) {
      return await findOrCreateUserVault(api);
    }
    return await findOrCreateLocalVault();
  }

  @override
  VaultEntityState buildStateFromEntities(List<Vault> entities) =>
      state.copyWith(entities: entities);
}
