import 'package:cliq/modules/settings/data/known_host.service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<KnownHostService> knownHostServiceProvider = Provider(
  (ref) => KnownHostService(ref.read(databaseProvider).knownHostsRepository),
);
