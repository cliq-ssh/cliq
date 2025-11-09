import 'package:cliq/shared/data/sqlite/database.dart';

class IdentityFull {
  final int id;
  final String username;
  final Credential credential;

  const IdentityFull({
    required this.id,
    required this.username,
    required this.credential,
  });

  Identity toBaseClass() {
    return Identity(id: id, username: username, credentialId: credential.id);
  }
}
