import 'package:cliq/modules/connections/data/connections.repository.dart';
import 'package:cliq/modules/identities/data/identities.repository.dart';
import 'package:cliq/modules/keys/data/key.repository.dart';
import 'package:cliq/modules/settings/data/known_hosts.repository.dart';
import 'package:cliq/modules/vaults/data/vaults.repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

final class VaultService {
  final VaultsRepository _vaultsRepository;

  final ConnectionsRepository _connectionsRepository;
  final IdentitiesRepository _identitiesRepository;
  final KeyRepository _keyRepository;
  final KnownHostsRepository _knownHostsRepository;

  const new(
    this._vaultsRepository,
    this._connectionsRepository,
    this._identitiesRepository,
    this._keyRepository,
    this._knownHostsRepository,
  );

  Stream<List<Vault>> watchAll() => _vaultsRepository.selectAll().watch();

  Future<Vault> createVault({required String? owner}) async {
    return await _vaultsRepository.insert(
      VaultsCompanion.insert(owner: .absentIfNull(owner)),
    );
  }

  Future<
    (
      int connections,
      int identities,
      int keys,
      int knownHosts,
      int colorSchemes,
    )
  >
  countEntitiesInVault(DbId vaultId) async {
    final connectionsCount = await _connectionsRepository.count(
      where: (c) => c.vaultId.equals(vaultId),
    );
    final identitiesCount = await _identitiesRepository.count(
      where: (i) => i.vaultId.equals(vaultId),
    );
    final keysCount = await _keyRepository.count(
      where: (k) => k.vaultId.equals(vaultId),
    );
    final knownHostsCount = await _knownHostsRepository.count(
      where: (kh) => kh.vaultId.equals(vaultId),
    );
    // we only count connections which have an override set as color schemes are stored globally
    // this more or less means "color schemes synced due to connections in this vault"
    final colorSchemesCount = await _connectionsRepository.count(
      where: (c) =>
          c.vaultId.equals(vaultId) & c.terminalThemeOverrideId.isNotNull(),
    );

    return (
      connectionsCount,
      identitiesCount,
      keysCount,
      knownHostsCount,
      colorSchemesCount,
    );
  }

  Future<void> clearByVaultId(DbId vaultId) async {
    await _vaultsRepository.db.clearConnectionsByVaultId(vaultId);
    await _vaultsRepository.db.clearIdentitiesByVaultId(vaultId);
    await _vaultsRepository.db.clearCredentialsByVaultId(vaultId);
    await _vaultsRepository.db.clearKeysByVaultId(vaultId);
    await _vaultsRepository.db.clearKnownHostsByVaultId(vaultId);
  }

  Future<void> deleteById(DbId id) => _vaultsRepository.deleteById(id);
}
