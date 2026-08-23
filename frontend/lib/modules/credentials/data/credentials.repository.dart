import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class CredentialsRepository extends Repository<Credentials, Credential> {
  new(super.db);

  @override
  TableInfo<Credentials, Credential> get table => db.credentials;
}
