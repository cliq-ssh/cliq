import '../../../shared/data/database.dart';

class CredentialFull extends Credential {
  final Key? key;

  const CredentialFull({
    required super.id,
    required super.type,
    required super.keyId,
    required super.password,
    this.key,
  });

  CredentialFull.fromCredential(Credential credential, {this.key})
    : super(
        id: credential.id,
        type: credential.type,
        keyId: credential.keyId,
        password: credential.password,
      );

  factory CredentialFull.fromResult(FindCredentialFullByIdsResult result) {
    return .fromCredential(result.credential, key: result.credentialKey);
  }
}
