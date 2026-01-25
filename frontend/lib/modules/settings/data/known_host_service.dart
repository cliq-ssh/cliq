import 'package:cliq/modules/settings/data/known_hosts_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../../../shared/extensions/value.extension.dart';

final class KnownHostService {
  final KnownHostsRepository _knownHostsRepository;

  const KnownHostService(this._knownHostsRepository);

  Stream<List<KnownHost>> watchAll() =>
      _knownHostsRepository.selectAll().watch();

  /// Whether or not the [host] is known, and if so, whether the [hostKey] matches.
  Future<(KnownHostsCompanion?, bool)> isHostKnown(
    String host,
    Uint8List hostKey,
  ) async {
    final knownHosts = await _knownHostsRepository.db
        .findKnownHostByHost(host)
        .get();

    if (knownHosts.isEmpty) {
      return (null, false);
    }
    for (final knownHost in knownHosts) {
      if (String.fromCharCodes(knownHost.hostKey) ==
          String.fromCharCodes(hostKey)) {
        return (
          KnownHostsCompanion(
            host: Value(knownHost.host),
            hostKey: Value(knownHost.hostKey),
            createdAt: Value(knownHost.createdAt),
          ),
          true,
        );
      }
    }
    return (null, false);
  }

  Future<int> createKey({required String host, required Uint8List hostKey}) =>
      _knownHostsRepository.insert(
        KnownHostsCompanion.insert(
          host: host.trim(),
          hostKey: hostKey,
          createdAt: Value(DateTime.now()),
        ),
      );

  Future<int> update(
    int id, {
    required Uint8List? hostKey,
    KnownHostsCompanion? compareTo,
  }) => _knownHostsRepository.updateById(
    id,
    KnownHostsCompanion(
      hostKey: ValueExtension.absentIfNullOrSame(hostKey, compareTo?.hostKey),
    ),
  );

  Future<void> deleteById(int id) => _knownHostsRepository.deleteById(id);
}
