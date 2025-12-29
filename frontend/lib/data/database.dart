import 'package:cliq/data/connections/connection_service.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../modules/connections/model/connection_color.dart';
import '../modules/connections/model/connection_icon.dart';
import 'connections/connections_repository.dart';
import 'credentials/credential_service.dart' show CredentialService;
import 'credentials/credentials_repository.dart';
import 'credentials/credential_type.dart';
import 'identities/identities_repository.dart';
import 'identities/identity_service.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {
    'connections/connections.drift',
    'credentials/credentials.drift',
    'identities/identities.drift',
  },
)
final class CliqDatabase extends _$CliqDatabase {
  static late CredentialsRepository credentialsRepository;
  static late CredentialService credentialService;

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
