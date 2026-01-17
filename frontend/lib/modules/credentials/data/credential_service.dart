import 'package:cliq/modules/credentials/model/credential_full.model.dart';

import 'credentials_repository.dart';

final class CredentialService {
  final CredentialsRepository credentialRepository;

  const CredentialService(this.credentialRepository);

  Future<List<CredentialFull>> findByIds(List<int> ids) {
    return credentialRepository.db
        .findCredentialFullByIds(ids)
        .map(CredentialFull.fromResult)
        .get();
  }
}
