import 'dart:async';

import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../model/vault.state.dart';

final vaultProvider = NotifierProvider(VaultNotifier.new);

class VaultNotifier extends AbstractEntityNotifier<Vault, VaultEntityState> {
  @override
  VaultEntityState buildInitialState() => .initial();
  @override
  Stream<List<Vault>> get entityStream =>
      ref.read(vaultServiceProvider).watchAll();

  Vault? findById(int id) {
    for (final vault in state.entities) {
      if (vault.id == id) {
        return vault;
      }
    }
    return null;
  }

  /// Finds or creates the user's default vault called "My Vault".
  Future<Vault> findOrCreateDefaultVault(BuildContext context) async {
    await initialized;

    for (final vault in state.entities) {
      if (vault.isDefault) {
        return vault;
      }
    }

    // not found; create default vault
    final label = 'My Vault'; // TODO i18n
    final newId = await ref
        .read(vaultServiceProvider)
        .createVault(label: label, isDefault: true);

    return Vault(id: newId, label: label, isDefault: true);
  }

  @override
  VaultEntityState buildStateFromEntities(List<Vault> entities) =>
      state.copyWith(entities: entities);
}
