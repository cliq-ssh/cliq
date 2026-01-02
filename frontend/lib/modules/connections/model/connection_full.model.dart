import '../../../shared/data/database.dart';
import '../../identities/model/identity_full.model.dart';

/// Model class that better wraps the [FindFullConnectionByIdResult] class.
class ConnectionFull extends Connection {
  final IdentityFull? identity;
  final Credential? credential;

  String get effectiveUsername => username ?? identity!.username;
  Credential? get effectiveCredential => credential ?? identity?.credential;

  const ConnectionFull({
    required super.id,
    required super.address,
    required super.port,
    required super.icon,
    this.identity,
    this.credential,
    super.username,
    super.label,
    super.groupName,
    super.color,
  });

  static ConnectionFull fromResult(FindAllConnectionFullResult result) {
    return ConnectionFull(
      id: result.connectionId,
      address: result.address,
      port: result.port,
      icon: result.icon,
      color: result.color,
      groupName: result.groupName,
      label: result.label,
      username: result.connectionUsername,
      credential: result.connectionCredentialRefId != null
          ? Credential(
              id: result.connectionCredentialRefId!,
              type: result.connectionCredentialType!,
              data: result.connectionCredentialData!,
              passphrase: result.connectionCredentialPassphrase,
            )
          : null,
      identity: result.identityId != null
          ? IdentityFull(
              id: result.identityId!,
              username: result.identityUsername!,
              credentialId: result.identityCredentialRefId!,
              credential: Credential(
                id: result.identityCredentialRefId!,
                type: result.identityCredentialType!,
                data: result.identityCredentialData!,
                passphrase: result.identityCredentialPassphrase,
              ),
            )
          : null,
    );
  }
}
