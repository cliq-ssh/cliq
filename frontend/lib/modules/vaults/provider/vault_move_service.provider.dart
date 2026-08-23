import 'package:cliq/modules/connections/provider/connection_service.provider.dart';
import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:cliq/modules/identities/provider/identity_service.provider.dart';
import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/modules/vaults/data/vault_move.service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<VaultMoveService> vaultMoveServiceProvider = Provider((ref) {
  final db = ref.read(databaseProvider);
  return VaultMoveService(
    db: db,
    connectionService: ref.read(connectionServiceProvider),
    identityService: ref.read(identityServiceProvider),
    credentialService: ref.read(credentialServiceProvider),
    keyService: ref.read(keyServiceProvider),
  );
});
