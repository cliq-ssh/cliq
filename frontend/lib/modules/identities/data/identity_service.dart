import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/identities/data/identity_credentials_repository.dart';
import 'package:cliq/modules/identities/model/identity_full.model.dart';

import '../../../shared/data/database.dart';
import 'identities_repository.dart';

final class IdentityService {
  final IdentitiesRepository _identityRepository;
  final IdentityCredentialsRepository _identityCredentialsRepository;

  final CredentialService _credentialService;

  const IdentityService(
    this._identityRepository,
    this._identityCredentialsRepository,
    this._credentialService,
  );

  Stream<List<IdentityFull>> watchAll() {
    return _identityRepository.db.findAllIdentityFull().watch().map(
      (c) => c.map(IdentityFull.fromFindAllResult).toList(),
    );
  }

  Future<int> createIdentity(
    IdentitiesCompanion identity,
    List<int> credentialIds,
  ) async {
    final identityId = await _identityRepository.insert(identity);
    await _credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: _identityCredentialsRepository,
      builder: (id) => IdentityCredentialsCompanion.insert(
        identityId: identityId,
        credentialId: id,
      ),
    );

    return identityId;
  }

  Future<int> update(
    int identityId,
    IdentitiesCompanion identity, [
    List<int>? newCredentialIds,
  ]) async {
    await _identityRepository.updateById(identityId, identity);

    if (newCredentialIds != null) {
      await _credentialService.insertAllWithRelation(
        newCredentialIds,
        relationRepository: _identityCredentialsRepository,
        builder: (id) => IdentityCredentialsCompanion.insert(
          identityId: identityId,
          credentialId: id,
        ),
      );
    }
    return identityId;
  }

  Future<void> deleteById(int id, List<int> credentialIds) async {
    await _credentialService.deleteByIds(credentialIds);
    return _identityRepository.deleteById(id);
  }
}
