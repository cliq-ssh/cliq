import 'package:cliq/data/sqlite/credentials/credentials_repository.dart';
import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/data/sqlite/identities/identity_connection_repository.dart';
import 'package:drift/drift.dart';

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

  Future<bool> hasIdentities() async => await identityRepository.count() > 0;

  Future<int> createIdentity(
    IdentitiesCompanion identity,
    List<int> orderedCredentialIds,
  ) async {
    if (orderedCredentialIds.isEmpty) {
      throw Exception(
        'At least one credential is required to create an identity',
      );
    }

    final credentials = await credentialRepository.findAllByIds(
      orderedCredentialIds,
    );

    for (final id in orderedCredentialIds) {
      if (credentials.indexWhere((c) => c.id == id) == -1) {
        throw Exception('Credential with id $id does not exist');
      }
    }

    final identityId = await identityRepository.insert(identity);
    await identityCredentialsRepository.insertAll([
      for (var i = 0; i < orderedCredentialIds.length; i++)
        IdentityCredentialsCompanion.insert(
          identityId: identityId,
          credentialId: orderedCredentialIds[i],
          priority: Value(i),
        ),
    ]);

    return identityId;
  }
}
