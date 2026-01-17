import 'package:cliq/modules/credentials/model/credential_full.model.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../../../shared/data/database.dart';
import '../model/credential_type.dart';
import 'credentials_repository.dart';

final class CredentialService {
  static final Logger _log = Logger('CredentialService');

  final CredentialsRepository credentialRepository;

  const CredentialService(this.credentialRepository);

  static (String?, List<SSHKeyPair>) collectAuthenticationMethods(
    List<CredentialFull> credentials,
  ) {
    String? password;
    final List<SSHKeyPair> keys = [];

    for (final credential in credentials) {
      switch (credential.type) {
        case .password:
          if (password != null) {
            _log.severe(
              'Multiple password credentials found while collecting authentication methods!',
            );
          }
          if (credential.password == null) {
            throw Exception('Password credential has null password!');
          }
          password = credential.password;
          break;
        case .key:
          if (credential.key == null) {
            throw Exception('Key credential has null key data!');
          }
          if (SSHKeyPair.isEncryptedPem(credential.key!.privatePem)) {
            if (credential.key!.passphrase == null) {
              throw Exception('Key is encrypted but no passphrase provided');
            }
            keys.addAll(
              SSHKeyPair.fromPem(
                credential.key!.privatePem,
                credential.key!.passphrase!,
              ),
            );
          } else {
            keys.addAll(SSHKeyPair.fromPem(credential.key!.privatePem));
          }
          break;
      }
    }

    return (password, keys);
  }

  Future<List<CredentialFull>> findByIds(List<int> ids) {
    return credentialRepository.db
        .findCredentialFullByIds(ids)
        .map(CredentialFull.fromResult)
        .get();
  }

  Future<List<int>> insertAllWithRelation<T extends Table, R>(
    List<CredentialsCompanion> credentials, {
    required Repository<T, R> relationRepository,
    required UpdateCompanion<R> Function(int) builder,
  }) async {
    final credentialIds = await credentialRepository.insertAll(credentials);

    await relationRepository.insertAllBatch(
      credentialIds.map((credentialId) => builder(credentialId)).toList(),
    );

    return credentialIds;
  }
}
