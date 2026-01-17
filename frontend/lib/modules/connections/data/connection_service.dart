import '../../credentials/data/credential_service.dart';
import '../../identities/data/identity_service.dart';
import '../model/connection_full.model.dart';
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
    return await connectionRepository.db
        .findAllConnectionGroupNames()
        .get()
        .then((groups) => groups.whereType<String>().toList());
  }

  Stream<List<ConnectionFull>> watchConnectionFullAll() {
    return connectionRepository.db.findAllConnectionFull().watch().map(
      (c) => c.map(ConnectionFull.fromFindAllResult).toList(),
    );
  }

  Future<void> deleteById(int id) => connectionRepository.deleteById(id);
}
