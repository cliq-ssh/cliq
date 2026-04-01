import 'dart:ui';

import 'package:cliq/modules/identities/data/identity_credentials_repository.dart';
import 'package:cliq/modules/settings/data/custom_terminal_themes_repository.dart';
import 'package:cliq/modules/vaults/data/vaults_repository.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../modules/connections/data/connection_credentials_repository.dart';
import '../../modules/connections/data/connections_repository.dart';
import '../../modules/connections/model/connection_icon.dart';
import '../../modules/credentials/data/credentials_repository.dart';
import '../../modules/credentials/model/credential_type.dart';
import '../../modules/identities/data/identities_repository.dart';
import '../../modules/keys/data/key_repository.dart';
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
    '../../modules/vaults/data/vaults.drift',
  },
)
final class CliqDatabase extends _$CliqDatabase {
  static late CliqDatabase instance;

  late final keysRepository = KeyRepository(this);
  late final credentialsRepository = CredentialsRepository(this);
  late final identitiesRepository = IdentitiesRepository(this);
  late final connectionsRepository = ConnectionsRepository(this);
  late final customTerminalThemesRepository = CustomTerminalThemesRepository(
    this,
  );
  late final knownHostsRepository = KnownHostsRepository(this);
  late final vaultsRepository = VaultsRepository(this);

  late final identityCredentialsRepository = IdentityCredentialsRepository(
    this,
  );
  late final connectionsCredentialsRepository = ConnectionCredentialsRepository(
    this,
  );

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

  Future<void> deleteAllTables() async {
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
