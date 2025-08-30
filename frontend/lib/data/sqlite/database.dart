import 'package:cliq/data/sqlite/connections/connections_repository.dart';
import 'package:cliq/data/sqlite/connections/connection_service.dart';
import 'package:cliq/data/sqlite/credentials/credential_service.dart';
import 'package:cliq/data/sqlite/identities/identity_connection_repository.dart';
import 'package:cliq/data/sqlite/identities/identity_service.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'credentials/credentials_repository.dart';
import 'credentials/credential_type.dart';
import 'identities/identities_repository.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {
    'connections/connections.drift',
    'credentials/credentials.drift',
    'identities/identities.drift',
    'identities/identity_credentials.drift',
  },
)
final class CliqDatabase extends _$CliqDatabase {
  static late ConnectionsRepository connectionsRepository;
  static late ConnectionService connectionService;

  static late CredentialsRepository credentialsRepository;
  static late CredentialService credentialService;

  static late IdentitiesRepository identitiesRepository;
  static late IdentityCredentialsRepository identityCredentialsRepository;
  static late IdentityService identityService;

  CliqDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static void init() {
    final db = CliqDatabase();
    connectionsRepository = ConnectionsRepository(db);
    connectionService = ConnectionService(connectionsRepository);

    credentialsRepository = CredentialsRepository(db);
    credentialService = CredentialService(credentialsRepository);

    identitiesRepository = IdentitiesRepository(db);
    identityCredentialsRepository = IdentityCredentialsRepository(db);
    identityService = IdentityService(
      identitiesRepository,
      identityCredentialsRepository,
      credentialsRepository,
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'cliq_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
