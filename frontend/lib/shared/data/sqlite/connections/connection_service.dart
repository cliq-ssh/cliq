import 'package:drift/drift.dart';

import '../database.dart';
import 'connections_repository.dart';

final class ConnectionService {
  final ConnectionsRepository connectionRepository;

  const ConnectionService(this.connectionRepository);

  // TODO: insert with identity
  // TODO: insert with credentials

  // TODO: query connections with identities AND credentials

  Future<List<(Connection, Identity?)>> findAllWithIdentities() async {
    final db = connectionRepository.db;

    final query = db.select(db.connections).join([
      leftOuterJoin(
        db.identities,
        db.identities.id.equalsExp(db.connections.identityId),
      ),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      final connection = row.readTable(db.connections);
      final identity = row.readTableOrNull(db.identities);
      return (connection, identity);
    }).toList();
  }
}
