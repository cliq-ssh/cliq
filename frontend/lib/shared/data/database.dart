import 'dart:ui';

import 'package:cliq/modules/connections/data/connection_service.dart';
import 'package:cliq/modules/identities/data/identity_credentials_repository.dart';
import 'package:cliq/modules/settings/data/custom_terminal_theme_service.dart';
import 'package:cliq/modules/settings/data/custom_terminal_themes_repository.dart';
import 'package:cliq/modules/settings/data/known_host_service.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../modules/connections/data/connection_credentials_repository.dart';
import '../../modules/connections/data/connections_repository.dart';
import '../../modules/connections/model/connection_icon.dart';
import '../../modules/credentials/data/credential_service.dart'
    show CredentialService;
import '../../modules/credentials/data/credentials_repository.dart';
import '../../modules/credentials/model/credential_type.dart';
import '../../modules/identities/data/identities_repository.dart';
import '../../modules/identities/data/identity_service.dart';
import '../../modules/keys/data/key_repository.dart';
import '../../modules/keys/data/key_service.dart';
import '../../modules/settings/data/known_hosts_repository.dart';
import 'converters/color_converter.dart';
import 'converters/terminal_typography_converter.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {
    '../../modules/connections/data/connections.drift',
    '../../modules/credentials/data/credentials.drift',
    '../../modules/identities/data/identities.drift',
    '../../modules/keys/data/keys.drift',
    '../../modules/settings/data/custom_terminal_themes.drift',
    '../../modules/settings/data/known_hosts.drift',
  },
)
final class CliqDatabase extends _$CliqDatabase {
  static late KeyService keysService;
  static late CredentialService credentialService;
  static late IdentityService identityService;
  static late ConnectionService connectionService;
  static late CustomTerminalThemeService customTerminalThemeService;
  static late KnownHostService knownHostService;

  CliqDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static void init() {
    final db = CliqDatabase();

    final keysRepository = KeyRepository(db);
    final credentialsRepository = CredentialsRepository(db);
    final identitiesRepository = IdentitiesRepository(db);
    final connectionsRepository = ConnectionsRepository(db);
    final customTerminalThemesRepository = CustomTerminalThemesRepository(db);
    final knownHostsRepository = KnownHostsRepository(db);

    final identityCredentialsRepository = IdentityCredentialsRepository(db);
    final connectionsCredentialsRepository = ConnectionCredentialsRepository(
      db,
    );

    keysService = KeyService(keysRepository);
    credentialService = CredentialService(credentialsRepository);
    identityService = IdentityService(
      identitiesRepository,
      identityCredentialsRepository,
      credentialService,
    );
    connectionService = ConnectionService(
      connectionsRepository,
      connectionsCredentialsRepository,
      credentialService,
    );
    customTerminalThemeService = CustomTerminalThemeService(
      customTerminalThemesRepository,
    );
    knownHostService = KnownHostService(knownHostsRepository);
  }

  Future<void> deleteAll() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    for (final table in allTables) {
      await delete(table).go();
    }
    await customStatement('PRAGMA foreign_keys = ON');
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
