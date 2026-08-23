import 'package:cliq/shared/data/database.dart';

class IdentityFull extends Identity {
  final List<DbId> credentialIds;
  final Vault vault;

  const new(
    this.vault, {
    required super.id,
    required super.vaultId,
    required super.label,
    required super.username,
    required this.credentialIds,
  });

  new fromIdentity(
    Identity identity, {
    required this.credentialIds,
    required this.vault,
  }) : super(
         id: identity.id,
         vaultId: identity.vaultId,
         label: identity.label,
         username: identity.username,
       );

  factory fromFindAllResult(FindAllIdentityFullResult result) {
    return IdentityFull.fromIdentity(
      result.identity,
      credentialIds: result.identityCredentials,
      vault: result.vault,
    );
  }
}
