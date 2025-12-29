import 'package:cliq/modules/connections/model/connection_full.model.dart';

import '../../../shared/data/database.dart';
import '../../identities/model/identity_full.model.dart';

extension ConnectionExtension on Connection {
  String get effectiveName => label ?? address;
}

extension FindFullConnectionByIdResultExtension
    on FindFullConnectionByIdResult {
  ConnectionFull toConnectionFull() {
    return ConnectionFull(
      id: connectionId,
      address: address,
      port: port,
      identity: identityId == null
          ? null
          : IdentityFull(
              id: identityId!,
              username: identityUsername!,
              credential: Credential(
                id: identityCredentialId!,
                type: identityCredentialType!,
                data: identityCredentialData!,
                passphrase: identityCredentialPassphrase,
              ),
            ),
      credential: connectionCredentialId == null
          ? null
          : Credential(
              id: connectionCredentialId!,
              type: connectionCredentialType!,
              data: connectionCredentialData!,
              passphrase: connectionCredentialPassphrase,
            ),
      username: connectionUsername,
      label: label,
      icon: icon,
      colorHex: color,
      group: groupName,
    );
  }
}
