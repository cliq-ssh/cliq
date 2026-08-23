import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class ConnectionsRepository extends Repository<Connections, Connection> {
  new(super.db);

  @override
  TableInfo<Connections, Connection> get table => db.connections;
}
