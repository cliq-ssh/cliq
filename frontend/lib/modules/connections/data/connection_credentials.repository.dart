import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';
import '../../../shared/data/repository.dart';

final class ConnectionCredentialsRepository
    extends Repository<ConnectionCredentials, ConnectionCredential> {
  ConnectionCredentialsRepository(super.db);

  @override
  TableInfo<ConnectionCredentials, ConnectionCredential> get table =>
      db.connectionCredentials;
}
