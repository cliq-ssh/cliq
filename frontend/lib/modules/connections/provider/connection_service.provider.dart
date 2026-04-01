import 'package:cliq/modules/connections/data/connection_service.dart';
import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/provider/database.provider.dart';

final Provider<ConnectionService> connectionServiceProvider = Provider((ref) {
  final db = ref.read(databaseProvider);
  return ConnectionService(
    db.connectionsRepository,
    db.connectionsCredentialsRepository,
    ref.read(credentialServiceProvider),
  );
});
