import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class IdentityCredentialsRepository
    extends Repository<IdentityCredentials, IdentityCredential> {
  new(super.db);

  @override
  TableInfo<IdentityCredentials, IdentityCredential> get table =>
      db.identityCredentials;
}
