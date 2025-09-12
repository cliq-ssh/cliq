import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/data/sqlite/repository.dart';
import 'package:drift/drift.dart';

final class ConnectionsRepository extends Repository<Connections, Connection> {
  ConnectionsRepository(super.db);

  @override
  TableInfo<Connections, Connection> get table => db.connections;
}
