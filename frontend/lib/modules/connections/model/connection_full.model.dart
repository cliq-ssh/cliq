import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/modules/settings/model/custom_terminal_theme.state.dart';
import 'package:cliq/modules/settings/provider/custom_terminal_theme.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/filterable.dart';

/// Model class that better wraps the [FindFullConnectionByIdResult] class.
class ConnectionFull extends Connection implements Filterable {
  final List<DbId> credentialIds;
  final Vault vault;
  final IdentityFull? identity;
  final CustomTerminalTheme? terminalThemeOverride;

  String get addressAndPort => '[$address]:$port';
  String? get effectiveUsername => identity?.username ?? username;

  CustomTerminalTheme getEffectiveTerminalTheme(
    CustomTerminalThemeState themes,
    DbId defaultTerminalThemeId,
  ) {
    return terminalThemeOverride ??
        themes.findById(defaultTerminalThemeId, isDefaultTheme: true)!;
  }

  new fromConnection(
    Connection connection, {
    required this.credentialIds,
    required this.vault,
    this.identity,
    this.terminalThemeOverride,
  }) : super(
         id: connection.id,
         vaultId: connection.vaultId,
         address: connection.address,
         port: connection.port,
         icon: connection.icon,
         iconColor: connection.iconColor,
         iconBackgroundColor: connection.iconBackgroundColor,
         groupName: connection.groupName,
         label: connection.label,
         username: connection.username,
         identityId: connection.identityId,
         terminalTypographyOverride: connection.terminalTypographyOverride,
         terminalThemeOverrideId: connection.terminalThemeOverrideId,
         usesDefaultThemeOverride: connection.usesDefaultThemeOverride,
       );

  factory fromFindAllResult(FindAllConnectionFullResult result) {
    IdentityFull? identityFull;
    if (result.identity != null) {
      identityFull = IdentityFull.fromIdentity(
        result.identity!,
        credentialIds: result.identityCredentials,
        // we can be sure this is not null since the identity is not null
        vault: result.identityVault!,
      );
    }

    return .fromConnection(
      result.connection,
      vault: result.vault,
      identity: identityFull,
      // we need this check in order to correctly apply when the default "built-in" theme is used as an override
      // (when another theme is specified as the default)
      // otherwise we would fail since we dont have a db relation for the default terminal theme
      terminalThemeOverride: result.connection.usesDefaultThemeOverride
          ? defaultTerminalColorTheme
          : result.terminalThemeOverride,
      credentialIds: result.connectionCredentials,
    );
  }

  @override
  List<String> getFilterableFields() => [
    ?vault.owner,
    label,
    ?effectiveUsername,
    port.toString(),
  ];
}
