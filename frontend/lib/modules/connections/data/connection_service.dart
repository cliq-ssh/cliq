import 'package:cliq/modules/connections/data/connection_credentials_repository.dart';
import 'package:cliq/shared/data/database.dart';

import '../../credentials/data/credential_service.dart';
import '../model/connection_full.model.dart';
import 'connections_repository.dart';

final class ConnectionService {
  final ConnectionsRepository _connectionRepository;
  final ConnectionCredentialsRepository _connectionCredentialsRepository;

  final CredentialService _credentialService;

  const ConnectionService(
    this._connectionRepository,
    this._connectionCredentialsRepository,
    this._credentialService,
  );

  Future<List<String>> findAllGroupNamesDistinct() async {
    return await _connectionRepository.db
        .findAllConnectionGroupNames()
        .get()
        .then((groups) => groups.whereType<String>().toList());
  }

  Stream<List<ConnectionFull>> watchAll() {
    return _connectionRepository.db.findAllConnectionFull().watch().map(
      (c) => c.map(ConnectionFull.fromFindAllResult).toList(),
    );
  }

  Future<int> createConnection(
    ConnectionsCompanion connection,
    List<int> credentialIds,
  ) async {
    final connectionId = await _connectionRepository.insert(connection);
    await _credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: _connectionCredentialsRepository,
      builder: (id) => ConnectionCredentialsCompanion.insert(
        connectionId: connectionId,
        credentialId: id,
      ),
    );
    return connectionId;
  }

  Future<int> update(
    int connectionId,
    ConnectionsCompanion connection, [
    List<int>? newCredentialIds,
  ]) async {
    await _connectionRepository.updateById(connectionId, connection);

    if (newCredentialIds != null) {
      await _credentialService.insertAllWithRelation(
        newCredentialIds,
        relationRepository: _connectionCredentialsRepository,
        builder: (id) => ConnectionCredentialsCompanion.insert(
          connectionId: connectionId,
          credentialId: id,
        ),
      );
    }
    return connectionId;
  }

  Future<void> deleteById(int id, List<int> credentialIds) async {
    await _credentialService.deleteByIds(credentialIds);
    return _connectionRepository.deleteById(id);
  }
}
