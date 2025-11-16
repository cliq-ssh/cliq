import 'package:drift/drift.dart';

import '../database.dart';
import '../repository.dart';

final class ConnectionsRepository extends Repository<Connections, Connection> {
  ConnectionsRepository(super.db);

  @override
  TableInfo<Connections, Connection> get table => db.connections;
}
