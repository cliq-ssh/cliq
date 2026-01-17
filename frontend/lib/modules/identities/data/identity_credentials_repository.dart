import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';
import '../../../shared/data/repository.dart';

final class IdentityCredentialsRepository
    extends Repository<IdentityCredentials, IdentityCredential> {
  IdentityCredentialsRepository(super.db);

  @override
  TableInfo<IdentityCredentials, IdentityCredential> get table =>
      db.identityCredentials;
}
