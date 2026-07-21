import 'package:cliq/modules/vaults/data/vault_service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<VaultService> vaultServiceProvider = Provider((ref) {
  final db = ref.read(databaseProvider);
  return VaultService(
    db.vaultsRepository,
    db.connectionsRepository,
    db.identitiesRepository,
    db.keysRepository,
    db.knownHostsRepository,
  );
});
