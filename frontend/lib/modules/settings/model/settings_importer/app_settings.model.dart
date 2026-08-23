import 'package:cliq/modules/connections/extension/connections_companion.extension.dart';
import 'package:cliq/modules/credentials/extension/credentials_companion.extension.dart';
import 'package:cliq/modules/identities/extension/identities_companion.extension.dart';
import 'package:cliq/modules/keys/extension/keys_companion.extension.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_themes_companion.extension.dart';
import 'package:cliq/modules/settings/extension/known_hosts_companion.extension.dart';
import 'package:cliq/shared/data/database.dart';

/// Data class representing the app settings for import/export operations and synchronization.
class AppSettings {
  final List<ConnectionsCompanion>? connections;
  final List<IdentitiesCompanion>? identities;
  final List<KnownHostsCompanion>? knownHosts;
  final List<CustomTerminalThemesCompanion>? customTerminalThemes;
  final List<CredentialsCompanion>? credentials;
  final List<KeysCompanion>? keys;

  final Map<DbId, List<DbId>>? connectionsCredentialIds;
  final Map<DbId, List<DbId>>? identitiesCredentialIds;

  const new({
    required this.connections,
    required this.identities,
    required this.knownHosts,
    required this.customTerminalThemes,
    required this.credentials,
    required this.keys,
    required this.connectionsCredentialIds,
    required this.identitiesCredentialIds,
  });

  const new empty()
    : connections = null,
      identities = null,
      knownHosts = null,
      customTerminalThemes = null,
      credentials = null,
      keys = null,
      connectionsCredentialIds = null,
      identitiesCredentialIds = null;

  static AppSettings? tryFromJson(Map<String, dynamic> json) {
    parse<T>(T? Function(Map<String, dynamic>?) parser, String key) {
      return json[key] is List
          ? (json[key] as List)
                .map((item) => parser(item as Map<String, dynamic>))
                .whereType<T>()
                .toList()
          : null;
    }

    parseCredentialIds(String key) {
      return json[key] is Map<String, dynamic>
          ? (json[key] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as List).map((e) => e as DbId).toList()),
            )
          : null;
    }

    return AppSettings(
      connections: parse(
        ConnectionsCompanionExtension.tryFromJson,
        'connections',
      ),
      identities: parse(IdentitiesCompanionExtension.tryFromJson, 'identities'),
      knownHosts: parse(KnownHostsCompanionExtension.tryFromJson, 'knownHosts'),
      customTerminalThemes: parse(
        CustomTerminalThemesCompanionExtension.tryFromJson,
        'customTerminalThemes',
      ),
      credentials: parse(
        CredentialsCompanionExtension.tryFromJson,
        'credentials',
      ),
      keys: parse(KeysCompanionExtension.tryFromJson, 'keys'),
      connectionsCredentialIds: parseCredentialIds('connectionCredentialIds'),
      identitiesCredentialIds: parseCredentialIds('identityCredentialIds'),
    );
  }

  bool get isEmpty =>
      (connections == null || connections!.isEmpty) &&
      (identities == null || identities!.isEmpty) &&
      (knownHosts == null || knownHosts!.isEmpty) &&
      (customTerminalThemes == null || customTerminalThemes!.isEmpty) &&
      (credentials == null || credentials!.isEmpty) &&
      (keys == null || keys!.isEmpty);

  Map<String, dynamic> toJson() {
    return {
      // TODO: implement version handling for future changes to the settings structure
      'version': 1,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      if (connections?.isNotEmpty == true)
        'connections': connections!.map((c) => c.toJson()).toList(),
      if (connectionsCredentialIds?.isNotEmpty == true)
        'connectionCredentialIds': connectionsCredentialIds!.map(
          (k, v) => .new(k, v),
        ),
      if (identities?.isNotEmpty == true)
        'identities': identities!.map((i) => i.toJson()).toList(),
      if (identitiesCredentialIds?.isNotEmpty == true)
        'identityCredentialIds': identitiesCredentialIds!.map(
          (k, v) => .new(k, v),
        ),
      if (knownHosts?.isNotEmpty == true)
        'knownHosts': knownHosts!.map((k) => k.toJson()).toList(),
      if (customTerminalThemes?.isNotEmpty == true)
        'customTerminalThemes': customTerminalThemes!
            .map((t) => t.toJson())
            .toList(),
      if (credentials?.isNotEmpty == true)
        'credentials': credentials!.map((c) => c.toJson()).toList(),
      if (keys?.isNotEmpty == true)
        'keys': keys!.map((k) => k.toJson()).toList(),
    };
  }
}
