import '../../../shared/data/database.dart';

class IdentityFull extends Identity {
  final List<int> credentialIds;

  const IdentityFull({
    required super.id,
    required super.label,
    required super.username,
    required this.credentialIds,
  });

  IdentityFull.fromIdentity(Identity identity, {required this.credentialIds})
    : super(
        id: identity.id,
        label: identity.label,
        username: identity.username,
      );

  factory IdentityFull.fromFindAllResult(FindAllIdentityFullResult result) {
    return IdentityFull.fromIdentity(
      result.identity,
      credentialIds: result.identityCredentials,
    );
  }
}
