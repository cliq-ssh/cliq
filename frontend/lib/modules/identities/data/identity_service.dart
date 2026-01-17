import 'package:cliq/modules/identities/data/identity_credentials_repository.dart';
import 'package:cliq/modules/identities/model/identity_full.model.dart';

import '../../credentials/data/credentials_repository.dart';
import '../../../shared/data/database.dart';
import 'identities_repository.dart';

final class IdentityService {
  final IdentitiesRepository identityRepository;
  final IdentityCredentialsRepository identityCredentialsRepository;

  final CredentialsRepository credentialRepository;

  const IdentityService(
    this.identityRepository,
    this.identityCredentialsRepository,
    this.credentialRepository,
  );

  Stream<List<IdentityFull>> watchAll() {
    return identityRepository.db.findAllIdentityFull().watch().map(
      (c) => c.map(IdentityFull.fromFindAllResult).toList(),
    );
  }

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
