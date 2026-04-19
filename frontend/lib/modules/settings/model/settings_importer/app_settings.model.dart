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

  const AppSettings({
    required this.connections,
    required this.identities,
    required this.knownHosts,
    required this.credentials,
    required this.keys,
  });

  const AppSettings.empty()
    : connections = null,
      identities = null,
      knownHosts = null,
      credentials = null,
      keys = null;

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

    return AppSettings(
      connections: connections,
      identities: identities,
      knownHosts: knownHosts,
      credentials: credentials,
      keys: keys,
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
      if (connections != null)
        'connections': connections!.map((c) => c.toJson()).toList(),
      if (identities != null)
        'identities': identities!.map((i) => i.toJson()).toList(),
      if (knownHosts != null)
        'knownHosts': knownHosts!.map((k) => k.toJson()).toList(),
      if (credentials != null)
        'credentials': credentials!.map((c) => c.toJson()).toList(),
      if (keys != null) 'keys': keys!.map((k) => k.toJson()).toList(),
    };
  }
}
