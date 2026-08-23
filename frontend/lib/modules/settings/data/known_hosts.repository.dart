import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class KnownHostsRepository extends Repository<KnownHosts, KnownHost> {
  new(super.db);

  @override
  TableInfo<KnownHosts, KnownHost> get table => db.knownHosts;
}
