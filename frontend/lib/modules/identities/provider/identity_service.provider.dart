import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:cliq/modules/identities/data/identity_service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<IdentityService> identityServiceProvider = Provider((ref) {
  final db = ref.read(databaseProvider);
  return IdentityService(
    db.identitiesRepository,
    db.identityCredentialsRepository,
    ref.read(credentialServiceProvider),
  );
});
