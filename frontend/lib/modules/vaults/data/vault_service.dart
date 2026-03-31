import 'package:cliq/modules/vaults/data/vaults_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

final class VaultService {
  final VaultsRepository _vaultsRepository;

  const VaultService(this._vaultsRepository);

  Stream<List<Vault>> watchAll() => _vaultsRepository.selectAll().watch();

  Future<int> createVault({
    required String label,
    required bool isDefault,
  }) async {
    return await _vaultsRepository.insert(
      VaultsCompanion.insert(label: label, isDefault: Value(isDefault)),
    );
  }
}
