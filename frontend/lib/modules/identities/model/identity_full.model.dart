import '../../../shared/data/database.dart';

class IdentityFull extends Identity {
  final Credential? credential;

  const IdentityFull({
    required super.id,
    required super.username,
    required super.credentialId,
    this.credential,
  });

  IdentityFull.fromIdentity(Identity identity, {this.credential})
    : super(
        id: identity.id,
        username: identity.username,
        credentialId: identity.credentialId,
      );
}
