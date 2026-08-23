import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class ConnectionCredentialsRepository
    extends Repository<ConnectionCredentials, ConnectionCredential> {
  new(super.db);

  @override
  TableInfo<ConnectionCredentials, ConnectionCredential> get table =>
      db.connectionCredentials;
}
