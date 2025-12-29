import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';
import '../../../shared/data/repository.dart';

final class ConnectionsRepository extends Repository<Connections, Connection> {
  ConnectionsRepository(super.db);

  @override
  TableInfo<Connections, Connection> get table => db.connections;
}
