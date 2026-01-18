import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/identities/data/identity_credentials_repository.dart';
import 'package:cliq/modules/identities/model/identity_full.model.dart';

import '../../../shared/data/database.dart';
import 'identities_repository.dart';

final class IdentityService {
  final IdentitiesRepository identityRepository;
  final IdentityCredentialsRepository identityCredentialsRepository;

  final CredentialService credentialService;

  const IdentityService(
    this.identityRepository,
    this.identityCredentialsRepository,
    this.credentialService,
  );

  Stream<List<IdentityFull>> watchAll() {
    return identityRepository.db.findAllIdentityFull().watch().map(
      (c) => c.map(IdentityFull.fromFindAllResult).toList(),
    );
  }

  Future<int> createIdentity(
    IdentitiesCompanion identity,
    List<int> credentialIds,
  ) async {
    final identityId = await identityRepository.insert(identity);
    await credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: identityCredentialsRepository,
      builder: (id) => IdentityCredentialsCompanion.insert(
        identityId: identityId,
        credentialId: id,
      ),
    );

    return identityId;
  }

  Future<void> deleteById(int id) => identityRepository.deleteById(id);
}
