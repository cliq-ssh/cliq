import 'package:cliq/modules/connections/data/connection_credentials_repository.dart';
import 'package:cliq/shared/data/database.dart';

import '../../credentials/data/credential_service.dart';
import '../../identities/data/identity_service.dart';
import '../model/connection_full.model.dart';
import 'connections_repository.dart';

final class ConnectionService {
  final ConnectionsRepository connectionRepository;
  final ConnectionCredentialsRepository connectionCredentialsRepository;

  final CredentialService credentialService;
  final IdentityService identityService;

  const ConnectionService(
    this.connectionRepository,
    this.connectionCredentialsRepository,
    this.credentialService,
    this.identityService,
  );

  Future<List<String>> findAllGroupNamesDistinct() async {
    return await connectionRepository.db
        .findAllConnectionGroupNames()
        .get()
        .then((groups) => groups.whereType<String>().toList());
  }

  Stream<List<ConnectionFull>> watchAll() {
    return connectionRepository.db.findAllConnectionFull().watch().map(
      (c) => c.map(ConnectionFull.fromFindAllResult).toList(),
    );
  }

  Future<int> createConnection(
    ConnectionsCompanion connection,
    List<int> credentialIds,
  ) async {
    final connectionId = await connectionRepository.insert(connection);
    await credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: connectionCredentialsRepository,
      builder: (id) => ConnectionCredentialsCompanion.insert(
        connectionId: connectionId,
        credentialId: id,
      ),
    );
    return connectionId;
  }

  Future<void> deleteById(int id, List<int> credentialIds) async {
    await credentialService.deleteByIds(credentialIds);
    return connectionRepository.deleteById(id);
  }
}
