import 'package:cliq/modules/connections/data/connection_service.dart';
import 'package:cliq/shared/data/sqlite/credentials/credential_service.dart';
import 'package:cliq/shared/data/sqlite/credentials/keys/key_service.dart';
import 'package:cliq/shared/data/sqlite/credentials/keys/keys_repository.dart';
import 'package:cliq/shared/data/sqlite/identities/identity_service.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../modules/connections/data/connections_repository.dart';
import 'credentials/credentials_repository.dart';
import 'credentials/credential_type.dart';
import 'identities/identities_repository.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {
    '../../../modules/connections/data/connections.drift',
    'credentials/credentials.drift',
    'credentials/keys/keys.drift',
    'identities/identities.drift',
  },
)
final class CliqDatabase extends _$CliqDatabase {
  static late CredentialsRepository credentialsRepository;
  static late CredentialService credentialService;
  static late KeysRepository keysRepository;
  static late KeyService keyService;

  static late IdentitiesRepository identitiesRepository;
  static late IdentityService identityService;

  static late ConnectionsRepository connectionsRepository;
  static late ConnectionService connectionService;

  CliqDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static void init() {
    final db = CliqDatabase();
    credentialsRepository = CredentialsRepository(db);
    credentialService = CredentialService(credentialsRepository);
    keysRepository = KeysRepository(db);
    keyService = KeyService(keysRepository);

    identitiesRepository = IdentitiesRepository(db);
    identityService = IdentityService(
      identitiesRepository,
      credentialsRepository,
    );

    connectionsRepository = ConnectionsRepository(db);
    connectionService = ConnectionService(
      connectionsRepository,
      credentialService,
      identityService,
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
