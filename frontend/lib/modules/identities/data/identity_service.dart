import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/modules/identities/data/identity_credentials_repository.dart';
import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/shared/extensions/value.extension.dart';

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

  Future<DbId> createIdentity({
    required DbId vaultId,
    required String label,
    required String username,
    required List<DbId> credentialIds,
  }) async {
    final identity = await _identityRepository.insert(
      IdentitiesCompanion.insert(
        vaultId: vaultId,
        label: label.trim(),
        username: username.trim(),
      ),
    );

    await _credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: _identityCredentialsRepository,
      builder: (id) => IdentityCredentialsCompanion.insert(
        identityId: identity.id,
        credentialId: id,
      ),
    );

    return identity.id;
  }

  Future<DbId> update(
    DbId identityId, {
    required DbId? vaultId,
    required String? label,
    required String? username,
    List<DbId>? newCredentialIds,
    IdentitiesCompanion? compareTo,
  }) async {
    await _identityRepository.updateById(
      identityId,
      IdentitiesCompanion(
        vaultId: ValueExtension.absentIfNullOrSame(vaultId, compareTo?.vaultId),
        label: ValueExtension.absentIfNullOrSame(label, compareTo?.label),
        username: ValueExtension.absentIfNullOrSame(
          username,
          compareTo?.username,
        ),
      ),
    );

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

  Future<void> deleteById(DbId id, List<DbId> credentialIds) async {
    await _credentialService.deleteByIds(credentialIds);
    return _identityRepository.deleteById(id);
  }
}
