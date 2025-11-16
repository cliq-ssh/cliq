import 'package:drift/drift.dart';

import '../database.dart';
import '../repository.dart';

final class CredentialsRepository extends Repository<Credentials, Credential> {
  CredentialsRepository(super.db);

  @override
  TableInfo<Credentials, Credential> get table => db.credentials;
}
