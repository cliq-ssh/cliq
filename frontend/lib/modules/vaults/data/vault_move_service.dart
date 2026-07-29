import '../../../shared/data/database.dart';
import '../../connections/data/connection_service.dart';
import '../../credentials/data/credential_service.dart';
import '../../identities/data/identity_service.dart';
import '../../keys/data/key_service.dart';

class MovePreview {
  final Set<DbId> connectionIds;
  final Set<DbId> identityIds;
  final Set<DbId> credentialIds;
  final Set<DbId> keyIds;

  const MovePreview({
    required this.connectionIds,
    required this.identityIds,
    required this.credentialIds,
    required this.keyIds,
  });
}

class VaultMoveService {
  final CliqDatabase db;
  final ConnectionService connectionService;
  final IdentityService identityService;
  final CredentialService credentialService;
  final KeyService keyService;

  const VaultMoveService({
    required this.db,
    required this.connectionService,
    required this.identityService,
    required this.credentialService,
    required this.keyService,
  });

  /// Computes the full set of entities that must move together, without
  /// making any changes.
  /// This simply crawls the graph of relationships between entities, starting from the provided seeds.
  Future<MovePreview> previewMove({
    Set<DbId> seedConnectionIds = const {},
    Set<DbId> seedIdentityIds = const {},
    Set<DbId> seedCredentialIds = const {},
    Set<DbId> seedKeyIds = const {},
  }) async {
    final connectionIds = {...seedConnectionIds};
    final identityIds = {...seedIdentityIds};
    final credentialIds = {...seedCredentialIds};
    final keyIds = {...seedKeyIds};

    var changed = true;
    while (changed) {
      // do until we reach a fixed point where no new entities are discovered
      changed = false;

      if (connectionIds.isNotEmpty) {
        final creds = await connectionService.findCredentialIdsByConnectionIds(
          connectionIds,
        );
        for (final id in connectionIds) {
          final identityId = await connectionService
              .findIdentityIdByConnectionId(id);
          if (identityId != null && identityIds.add(identityId)) changed = true;
        }
        final before = credentialIds.length;
        credentialIds.addAll(creds);
        if (credentialIds.length != before) changed = true;
      }

      if (identityIds.isNotEmpty) {
        final creds = await identityService.findCredentialIdsByIdentityIds(
          identityIds,
        );
        final beforeC = credentialIds.length;
        credentialIds.addAll(creds);
        if (credentialIds.length != beforeC) changed = true;

        final conns = await connectionService.findConnectionsByIdentityIds(
          identityIds,
        );
        final beforeConn = connectionIds.length;
        connectionIds.addAll(conns);
        if (connectionIds.length != beforeConn) changed = true;
      }

      if (credentialIds.isNotEmpty) {
        final keys = await credentialService.findKeyIdsByCredentialIds(
          credentialIds,
        );
        final beforeK = keyIds.length;
        keyIds.addAll(keys);
        if (keyIds.length != beforeK) changed = true;

        final idents = await identityService.findIdentityIdsByCredentialIds(
          credentialIds,
        );
        final beforeI = identityIds.length;
        identityIds.addAll(idents);
        if (identityIds.length != beforeI) changed = true;

        final conns = await connectionService.findConnectionIdsByCredentialIds(
          credentialIds,
        );
        final beforeConn = connectionIds.length;
        connectionIds.addAll(conns);
        if (connectionIds.length != beforeConn) changed = true;
      }

      if (keyIds.isNotEmpty) {
        final creds = await credentialService.findCredentialIdsByKeyIds(keyIds);
        final before = credentialIds.length;
        credentialIds.addAll(creds);
        if (credentialIds.length != before) changed = true;
      }
    }

    return MovePreview(
      connectionIds: connectionIds,
      identityIds: identityIds,
      credentialIds: credentialIds,
      keyIds: keyIds,
    );
  }

  /// Commits a previously-previewed move to [vaultId] in one transaction.
  Future<void> commitMove(MovePreview preview, DbId vaultId) async {
    await db.transaction(() async {
      if (preview.connectionIds.isNotEmpty) {
        await connectionService.moveToVault(preview.connectionIds, vaultId);
      }
      if (preview.identityIds.isNotEmpty) {
        await identityService.moveToVault(preview.identityIds, vaultId);
      }
      if (preview.credentialIds.isNotEmpty) {
        await credentialService.moveToVault(preview.credentialIds, vaultId);
      }
      if (preview.keyIds.isNotEmpty) {
        await keyService.moveToVault(preview.keyIds, vaultId);
      }
    });
  }
}
