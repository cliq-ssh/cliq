import 'package:cliq/modules/vaults/data/vaults_repository.dart';
import 'package:cliq/shared/data/database.dart';

final class VaultService {
  final VaultsRepository _vaultsRepository;

  const VaultService(this._vaultsRepository);

  Stream<List<Vault>> watchAll() => _vaultsRepository.selectAll().watch();
}
