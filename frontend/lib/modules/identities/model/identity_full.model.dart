import '../../../shared/data/database.dart';
import '../../credentials/model/credential_type.dart';

class IdentityFull extends Identity {
  final Map<CredentialType, int> credentialIds;

  const IdentityFull({
    required super.id,
    required super.username,
    required this.credentialIds,
  });

  IdentityFull.fromIdentity(Identity identity, {required this.credentialIds})
    : super(id: identity.id, username: identity.username);

  factory IdentityFull.fromFindAllResult(FindAllIdentityFullResult result) {
    return IdentityFull.fromIdentity(
      result.identity,
      credentialIds: result.identityCredentials.asMap().map(
        (_, cred) => MapEntry(cred.type, cred.id),
      ),
    );
  }
}
