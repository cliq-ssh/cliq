import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/data/sqlite/repository.dart';
import 'package:drift/drift.dart';

final class IdentityCredentialsRepository
    extends Repository<IdentityCredentials, IdentityCredential> {
  IdentityCredentialsRepository(super.db);

  @override
  TableInfo<IdentityCredentials, IdentityCredential> get table =>
      db.identityCredentials;
}
