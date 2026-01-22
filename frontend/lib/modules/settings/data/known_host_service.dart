import 'package:cliq/modules/settings/data/known_hosts_repository.dart';
import 'package:cliq/shared/data/database.dart';

final class KnownHostService {
  final KnownHostsRepository _knownHostsRepository;

  const KnownHostService(this._knownHostsRepository);

  Stream<List<KnownHost>> watchAll() =>
      _knownHostsRepository.selectAll().watch();

  /// Whether or not the [host] is known, and if so, whether the [fingerprint] matches.
  Future<(bool, bool)> isHostKnown(String host, String fingerprint) async {
    final knownHosts = await _knownHostsRepository.db
        .findKnownHostByHost(host)
        .get();

    if (knownHosts.isEmpty) {
      return (false, false);
    }
    for (final knownHost in knownHosts) {
      if (knownHost.fingerprint == fingerprint) {
        return (true, true);
      }
    }
    return (true, false);
  }
}
