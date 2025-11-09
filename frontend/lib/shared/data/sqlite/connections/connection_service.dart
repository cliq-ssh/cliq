import 'package:drift/drift.dart';

import '../database.dart';
import 'connections_repository.dart';

final class ConnectionService {
  final ConnectionsRepository connectionRepository;

  const ConnectionService(this.connectionRepository);

  // TODO: insert with identity
  // TODO: insert with credentials

  // TODO: query connections with identities AND credentials

  Future<List<Credential>> findCredentialsByConnectionId(
    Connection connection,
  ) {
    final db = connectionRepository.db;
    final credentialId = connection.credentialId;

    if (credentialId == null) {
      return Future.value([]);
    }

    final query = db.select(db.credentials)
      ..where((c) => c.id.equals(credentialId));
    return query.get();
  }

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
