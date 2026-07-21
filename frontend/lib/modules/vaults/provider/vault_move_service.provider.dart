import 'package:cliq/modules/connections/provider/connection_service.provider.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../credentials/provider/credential_service.provider.dart';
import '../../identities/provider/identity_service.provider.dart';
import '../../keys/provider/key_service.provider.dart';
import '../data/vault_move_service.dart';

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
