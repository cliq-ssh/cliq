import 'package:cliq/modules/credentials/model/credential_full.model.dart';
import 'package:cliq/modules/credentials/model/credential_type.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:cliq/shared/extensions/value.extension.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../shared/data/database.dart';
import 'credentials_repository.dart';

final class CredentialService {
  static final Logger _log = Logger('CredentialService');

  final CredentialsRepository _credentialRepository;

  const CredentialService(this._credentialRepository);

  static Future<(String?, List<SSHKeyPair>)> collectAuthenticationMethods(
    List<CredentialFull> credentials,
  ) async {
    String? password;
    final List<SSHKeyPair> keys = [];

    decryptKeyPairs(List<String> args) {
      return SSHKeyPair.fromPem(args[0], args[1]);
    }

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
          if (SSHKeyPair.isEncryptedPem(credential.key!.privateKey)) {
            if (credential.key!.passphrase == null) {
              throw Exception('Key is encrypted but no passphrase provided');
            }
            keys.addAll(
              await compute(decryptKeyPairs, [
                credential.key!.privateKey,
                credential.key!.passphrase!,
              ]),
            );
          } else {
            keys.addAll(
              await compute(decryptKeyPairs, [credential.key!.privateKey]),
            );
          }
          break;
      }
    }

    return (password, keys);
  }

  Future<List<CredentialFull>> findAll() {
    return _credentialRepository.db.findAllCredentialIds().get().then(
      (ids) => findByIds(ids),
    );
  }

  Future<List<CredentialFull>> findByIds(List<int> ids) {
    return _credentialRepository.db
        .findCredentialFullByIds(ids)
        .map(CredentialFull.fromResult)
        .get();
  }

  Future<int> createCredential({
    required int vaultId,
    required CredentialType type,
    required String data,
  }) async {
    final (password, keyId) = extractCredentialData(type, data);
    return await _credentialRepository.insert(
      CredentialsCompanion.insert(
        vaultId: vaultId,
        type: type,
        keyId: Value.absentIfNull(keyId),
        password: Value.absentIfNull(password),
      ),
    );
  }

  Future<List<int>> insertAllWithRelation<T extends Table, R>(
    List<int> credentialIds, {
    required Repository<T, R> relationRepository,
    required UpdateCompanion<R> Function(int) builder,
  }) async {
    await relationRepository.insertAllBatch(
      credentialIds.map((credentialId) => builder(credentialId)).toList(),
    );

    return credentialIds;
  }

  Future<int> update(
    int credentialId, {
    required int? vaultId,
    required CredentialType? type,
    required String? data,
    CredentialsCompanion? compareTo,
  }) async {
    final (password, keyId) = extractCredentialData(type, data);
    await _credentialRepository.updateById(
      credentialId,
      CredentialsCompanion(
        vaultId: ValueExtension.absentIfNullOrSame(vaultId, compareTo?.vaultId),
        password: ValueExtension.absentIfNullOrSame(
          password,
          compareTo?.password,
        ),
        keyId: ValueExtension.absentIfNullOrSame(keyId, compareTo?.keyId),
      ),
    );

    return credentialId;
  }

  Future<void> deleteByIds(List<int> ids) =>
      _credentialRepository.deleteByIds(ids);

  (String?, int?) extractCredentialData(CredentialType? type, String? data) {
    if (type == null || data == null) {
      return (null, null);
    }

    return switch (type) {
      .password => (data, null),
      .key => (null, int.parse(data)),
    };
  }
}
