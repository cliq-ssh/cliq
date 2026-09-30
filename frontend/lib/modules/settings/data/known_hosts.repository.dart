import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class KnownHostsRepository(super.db)
    extends Repository<KnownHosts, KnownHost> {
  @override
  TableInfo<KnownHosts, KnownHost> get table => db.knownHosts;
}
