import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:drift/drift.dart';

import '../../credentials/data/credential_service.dart';
import '../../../shared/data/database.dart';
import '../../identities/data/identity_service.dart';
import '../extension/connection.extension.dart';
import 'connections_repository.dart';

final class ConnectionService {
  final ConnectionsRepository connectionRepository;

  final CredentialService credentialService;
  final IdentityService identityService;

  const ConnectionService(
    this.connectionRepository,
    this.credentialService,
    this.identityService,
  );

  Future<List<String>> findAllGroupNamesDistinct() async {
    return await connectionRepository.db.findAllGroupNamesDistinct().get().then(
      (groups) => groups.whereType<String>().toList(),
    );
  }

  Future<ConnectionFull?> findConnectionFullById(int id) async {
    return await connectionRepository.db
        .findFullConnectionById(id)
        .getSingleOrNull()
        .then((value) => value?.toConnectionFull());
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
