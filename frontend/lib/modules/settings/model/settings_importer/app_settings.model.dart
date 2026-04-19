import 'package:cliq/shared/data/database.dart';

import '../../../connections/extension/connections_companion.extension.dart';
import '../../../credentials/extension/credentials_companion.extension.dart';
import '../../../identities/extension/identities_companion.extension.dart';
import '../../../keys/extension/keys_companion.extension.dart';
import '../../extension/known_hosts_companion.extension.dart';

/// Data class representing the app settings for import/export operations and synchronization.
class AppSettings {
  final List<ConnectionsCompanion> connections;
  final List<IdentitiesCompanion> identities;
  final List<KnownHostsCompanion> knownHosts;
  final List<CredentialsCompanion> credentials;
  final List<KeysCompanion> keys;

  const AppSettings({
    required this.connections,
    required this.identities,
    required this.knownHosts,
    required this.credentials,
    required this.keys,
  });

  static AppSettings? tryFromJson(Map<String, dynamic> json) {
    parse<T>(T? Function(Map<String, dynamic>?) parser, String key) {
      return json[key] is List
          ? (json[key] as List)
                .map((item) => parser(item as Map<String, dynamic>))
                .whereType<T>()
                .toList()
          : null;
    }

    final connections = parse(
      ConnectionsCompanionExtension.tryFromJson,
      'connections',
    );
    final identities = parse(
      IdentitiesCompanionExtension.tryFromJson,
      'identities',
    );
    final knownHosts = parse(
      KnownHostsCompanionExtension.tryFromJson,
      'knownHosts',
    );
    final credentials = parse(
      CredentialsCompanionExtension.tryFromJson,
      'credentials',
    );
    final keys = parse(KeysCompanionExtension.tryFromJson, 'keys');

    if (connections == null ||
        identities == null ||
        knownHosts == null ||
        credentials == null ||
        keys == null) {
      return null;
    }

    return AppSettings(
      connections: connections,
      identities: identities,
      knownHosts: knownHosts,
      credentials: credentials,
      keys: keys,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connections': connections.map((c) => c.toJson()).toList(),
      'identities': identities.map((i) => i.toJson()).toList(),
      'knownHosts': knownHosts.map((k) => k.toJson()).toList(),
      'credentials': credentials.map((c) => c.toJson()).toList(),
      'keys': keys.map((k) => k.toJson()).toList(),
    };
  }
}
