import 'dart:ui';

import 'package:cliq/modules/connections/data/connection_service.dart';
import 'package:cliq/modules/settings/data/custom_terminal_theme_service.dart';
import 'package:cliq/modules/settings/data/custom_terminal_themes_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../modules/connections/data/connections_repository.dart';
import '../../modules/connections/model/connection_icon.dart';
import '../../modules/credentials/data/credential_service.dart'
    show CredentialService;
import '../../modules/credentials/data/credentials_repository.dart';
import '../../modules/credentials/model/credential_type.dart';
import '../../modules/identities/data/identities_repository.dart';
import '../../modules/identities/data/identity_service.dart';
import 'converters/color_converter.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {
    '../../modules/connections/data/connections.drift',
    '../../modules/credentials/data/credentials.drift',
    '../../modules/identities/data/identities.drift',
    '../../modules/settings/data/custom_terminal_themes.drift',
  },
)
final class CliqDatabase extends _$CliqDatabase {
  static late CredentialsRepository credentialsRepository;
  static late CredentialService credentialService;

  static late IdentitiesRepository identitiesRepository;
  static late IdentityService identityService;

  static late ConnectionsRepository connectionsRepository;
  static late ConnectionService connectionService;

  static late CustomTerminalThemesRepository customTerminalThemesRepository;
  static late CustomTerminalThemeService customTerminalThemeService;

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

    customTerminalThemesRepository = CustomTerminalThemesRepository(db);
    customTerminalThemeService = CustomTerminalThemeService(
      customTerminalThemesRepository,
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
