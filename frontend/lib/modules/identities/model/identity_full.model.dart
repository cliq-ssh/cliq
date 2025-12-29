import '../../../shared/data/database.dart';

class IdentityFull {
  final int id;
  final String username;
  final Credential credential;

  const IdentityFull({
    required this.id,
    required this.username,
    required this.credential,
  });
}
