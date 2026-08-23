import 'package:cliq/modules/connections/data/connection.service.dart';
import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<ConnectionService> connectionServiceProvider = Provider((ref) {
  final db = ref.read(databaseProvider);
  return ConnectionService(
    db.connectionsRepository,
    db.connectionsCredentialsRepository,
    ref.read(credentialServiceProvider),
  );
});
