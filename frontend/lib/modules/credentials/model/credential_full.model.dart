import '../../../shared/data/database.dart';

class CredentialFull extends Credential {
  final Vault vault;
  final Key? key;

  const CredentialFull(
    this.vault,
    this.key, {
    required super.id,
    required super.vaultId,
    required super.type,
    required super.keyId,
    required super.password,
  });

  CredentialFull.fromCredential(
    Credential credential, {
    required this.vault,
    this.key,
  }) : super(
         id: credential.id,
         vaultId: credential.vaultId,
         type: credential.type,
         keyId: credential.keyId,
         password: credential.password,
       );

  factory CredentialFull.fromResult(FindCredentialFullByIdsResult result) {
    return .fromCredential(
      result.credential,
      vault: result.vault,
      key: result.credentialKey,
    );
  }
}
