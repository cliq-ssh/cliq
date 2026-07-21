import 'package:cliq/modules/connections/data/connections_repository.dart';
import 'package:cliq/modules/keys/data/key_repository.dart';
import 'package:cliq/modules/vaults/data/vaults_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../../identities/data/identities_repository.dart';
import '../../settings/data/known_hosts_repository.dart';

final class VaultService {
  final VaultsRepository _vaultsRepository;

  final ConnectionsRepository _connectionsRepository;
  final IdentitiesRepository _identitiesRepository;
  final KeyRepository _keyRepository;
  final KnownHostsRepository _knownHostsRepository;

  const VaultService(
    this._vaultsRepository,
    this._connectionsRepository,
    this._identitiesRepository,
    this._keyRepository,
    this._knownHostsRepository,
  );

  Stream<List<Vault>> watchAll() => _vaultsRepository.selectAll().watch();

  Future<Vault> createVault({
    required String label,
    required bool isDefault,
  }) async {
    return await _vaultsRepository.insert(
      VaultsCompanion.insert(label: label, isDefault: Value(isDefault)),
    );
  }

  Future<(int connections, int identities, int keys, int knownHosts)>
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
    return (connectionsCount, identitiesCount, keysCount, knownHostsCount);
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
