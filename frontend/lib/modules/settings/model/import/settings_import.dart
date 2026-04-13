import 'package:cliq/shared/data/database.dart';

class SettingsImport {
  final List<ConnectionsCompanion> connections;
  final List<IdentitiesCompanion> identities;
  final List<KnownHostsCompanion> knownHosts;
  final List<CredentialsCompanion> credentials;
  final List<KeysCompanion> keys;

  const SettingsImport({
    required this.connections,
    required this.identities,
    required this.knownHosts,
    required this.credentials,
    required this.keys,
  });
}
