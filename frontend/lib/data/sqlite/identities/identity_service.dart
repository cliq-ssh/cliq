import 'package:cliq/data/sqlite/credentials/credentials_repository.dart';
import 'package:cliq/data/sqlite/database.dart';

import 'identities_repository.dart';

final class IdentityService {
  final IdentitiesRepository identityRepository;
  final CredentialsRepository credentialRepository;

  const IdentityService(this.identityRepository, this.credentialRepository);

  Future<bool> hasIdentities() async => await identityRepository.count() > 0;

  Future<int> createIdentity(
    String username,
    CredentialsCompanion credential,
  ) async {
    final credentialId = await credentialRepository.insert(credential);
    return await identityRepository.insert(
      IdentitiesCompanion.insert(
        username: username,
        credentialId: credentialId,
      ),
    );
  }
}
