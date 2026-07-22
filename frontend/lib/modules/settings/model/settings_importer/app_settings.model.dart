import 'package:cliq/shared/data/database.dart';

import '../../../connections/extension/connections_companion.extension.dart';
import '../../../credentials/extension/credentials_companion.extension.dart';
import '../../../identities/extension/identities_companion.extension.dart';
import '../../../keys/extension/keys_companion.extension.dart';
import '../../extension/known_hosts_companion.extension.dart';

/// Data class representing the app settings for import/export operations and synchronization.
class AppSettings {
  final List<ConnectionsCompanion>? connections;
  final List<IdentitiesCompanion>? identities;
  final List<KnownHostsCompanion>? knownHosts;
  final List<CredentialsCompanion>? credentials;
  final List<KeysCompanion>? keys;

  final Map<DbId, List<DbId>>? connectionsCredentialIds;
  final Map<DbId, List<DbId>>? identitiesCredentialIds;

  const AppSettings({
    required this.connections,
    required this.identities,
    required this.knownHosts,
    required this.credentials,
    required this.keys,
    required this.connectionsCredentialIds,
    required this.identitiesCredentialIds,
  });

  const AppSettings.empty()
    : connections = null,
      identities = null,
      knownHosts = null,
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
          (k, v) => .new(k.toString(), v),
        ),
      if (identities?.isNotEmpty == true)
        'identities': identities!.map((i) => i.toJson()).toList(),
      if (identitiesCredentialIds?.isNotEmpty == true)
        'identityCredentialIds': identitiesCredentialIds!.map(
          (k, v) => .new(k.toString(), v),
        ),
      if (knownHosts?.isNotEmpty == true)
        'knownHosts': knownHosts!.map((k) => k.toJson()).toList(),
      if (credentials?.isNotEmpty == true)
        'credentials': credentials!.map((c) => c.toJson()).toList(),
      if (keys?.isNotEmpty == true)
        'keys': keys!.map((k) => k.toJson()).toList(),
    };
  }
}
