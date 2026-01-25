import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/repository.dart';

final class KnownHostsRepository extends Repository<KnownHosts, KnownHost> {
  KnownHostsRepository(super.db);

  @override
  TableInfo<KnownHosts, KnownHost> get table => db.knownHosts;
}
