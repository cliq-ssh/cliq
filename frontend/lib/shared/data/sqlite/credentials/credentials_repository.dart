import 'package:cliq/shared/data/sqlite/database.dart';
import 'package:cliq/shared/data/sqlite/repository.dart';
import 'package:drift/drift.dart';

final class CredentialsRepository extends Repository<Credentials, Credential> {
  CredentialsRepository(super.db);

  @override
  TableInfo<Credentials, Credential> get table => db.credentials;
}
