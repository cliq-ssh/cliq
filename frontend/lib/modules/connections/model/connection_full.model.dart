import 'package:cliq/modules/connections/model/connection_icons.dart';
import 'package:cliq/modules/settings/model/terminal_theme.state.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../shared/data/database.dart';
import '../../identities/model/identity_full.model.dart';

/// Model class that better wraps the [FindFullConnectionByIdResult] class.
class ConnectionFull extends Connection {
  final List<int> credentialIds;
  final Vault vault;
  final IdentityFull? identity;
  final CustomTerminalTheme? terminalThemeOverride;

  String get addressAndPort => '[$address]:$port';
  String? get effectiveUsername => identity?.username ?? username;

  CustomTerminalTheme getEffectiveTerminalTheme(
    CustomTerminalThemeState themes,
    int defaultTerminalThemeId,
  ) {
    return terminalThemeOverride ??
        themes.findById(defaultTerminalThemeId, isDefaultTheme: true)!;
  }

  ConnectionFull.fromConnection(
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

  factory ConnectionFull.fromFindAllResult(FindAllConnectionFullResult result) {
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

  static ConnectionFull buildLocalConnection(BuildContext context) {
    return .fromConnection(
      Connection(
        id: -1,
        vaultId: -1,
        label: 'local_connection'.tr(context: context),
        address: 'localhost',
        port: 22,
        username: '',
        identityId: null,
        icon: ConnectionIcons.laptop,
        iconColor: Colors.white,
        iconBackgroundColor: Colors.grey,
        usesDefaultThemeOverride: false,
      ),
      vault: Vault(id: -1, label: "My Vault", isDefault: true),
      credentialIds: [],
    );
  }
}
