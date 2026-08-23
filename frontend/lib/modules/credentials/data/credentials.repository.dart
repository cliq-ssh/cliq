import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';
import '../../../shared/data/repository.dart';

final class CredentialsRepository extends Repository<Credentials, Credential> {
  CredentialsRepository(super.db);

  @override
  TableInfo<Credentials, Credential> get table => db.credentials;
}
