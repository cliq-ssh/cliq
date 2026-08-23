import 'dart:io';
import 'dart:ui';

import 'package:cliq/modules/connections/data/connection_credentials.repository.dart';
import 'package:cliq/modules/connections/data/connections.repository.dart';
import 'package:cliq/modules/connections/model/connection_icons.model.dart';
import 'package:cliq/modules/credentials/data/credentials.repository.dart';
import 'package:cliq/modules/credentials/model/credential_type.model.dart';
import 'package:cliq/modules/identities/data/identities.repository.dart';
import 'package:cliq/modules/identities/data/identity_credentials.repository.dart';
import 'package:cliq/modules/keys/data/key.repository.dart';
import 'package:cliq/modules/settings/data/custom_terminal_themes.repository.dart';
import 'package:cliq/modules/settings/data/known_hosts.repository.dart';
import 'package:cliq/modules/vaults/data/vaults.repository.dart';
import 'package:cliq/shared/data/converters/color_converter.dart';
import 'package:cliq/shared/data/converters/terminal_typography_converter.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// A type alias for database identifiers, represented as strings (uuids)
typedef DbId = String;

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

  new([QueryExecutor? executor]) : super(executor ?? _openConnection());

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

  Future<void> deleteDatabaseFile() async {
    await executor.close();
    final supportDir = await getApplicationSupportDirectory();
    final dbFile = File('${supportDir.path}/cliq_db.sqlite');
    if (dbFile.existsSync()) {
      dbFile.deleteSync();
    }
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
