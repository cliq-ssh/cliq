import '../../../shared/data/database.dart';
import '../../identities/model/identity_full.model.dart';

/// Model class that better wraps the [FindFullConnectionByIdResult] class.
class ConnectionFull extends Connection {
  final IdentityFull? identity;
  final Credential? credential;
  final CustomTerminalTheme? terminalThemeOverride;

  String get effectiveUsername => username ?? identity!.username;
  Credential? get effectiveCredential => credential ?? identity?.credential;

  ConnectionFull.fromConnection(
    Connection connection, {
    this.identity,
    this.credential,
    this.terminalThemeOverride,
  }) : super(
         id: connection.id,
         address: connection.address,
         port: connection.port,
         icon: connection.icon,
         iconColor: connection.iconColor,
         iconBackgroundColor: connection.iconBackgroundColor,
         groupName: connection.groupName,
         label: connection.label,
         username: connection.username,
         terminalThemeOverrideId: connection.terminalThemeOverrideId,
         terminalTypographyOverride: connection.terminalTypographyOverride,
       );

  factory ConnectionFull.fromResult(FindAllConnectionFullResult result) {
    IdentityFull? identityFull;
    if (result.identity != null) {
      identityFull = IdentityFull.fromIdentity(
        result.identity!,
        credential: result.identityCredential,
      );
    }

    return .fromConnection(
      result.connection,
      identity: identityFull,
      credential: result.credential,
      terminalThemeOverride: result.terminalThemeOverride,
    );
  }
}
