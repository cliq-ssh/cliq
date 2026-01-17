import '../../../shared/data/database.dart';
import '../../identities/model/identity_full.model.dart';

/// Model class that better wraps the [FindFullConnectionByIdResult] class.
class ConnectionFull extends Connection {
  final List<int> credentialIds;
  final IdentityFull? identity;
  final CustomTerminalTheme? terminalThemeOverride;

  String get effectiveUsername => identity?.username ?? username!;

  ConnectionFull.fromConnection(
    Connection connection, {
    required this.credentialIds,
    this.identity,
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
         isIconAutoDetect: connection.isIconAutoDetect,
       );

  factory ConnectionFull.fromFindAllResult(FindAllConnectionFullResult result) {
    IdentityFull? identityFull;
    if (result.identity != null) {
      identityFull = IdentityFull.fromIdentity(
        result.identity!,
        credentialIds: result.identityCredentials,
      );
    }

    return .fromConnection(
      result.connection,
      identity: identityFull,
      terminalThemeOverride: result.terminalThemeOverride,
      credentialIds: result.connectionCredentials,
    );
  }
}
