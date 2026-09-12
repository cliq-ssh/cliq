import 'dart:ui';

import 'package:cliq/modules/connections/data/connection_credentials.repository.dart';
import 'package:cliq/modules/connections/data/connections.repository.dart';
import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/model/connection_icons.model.dart';
import 'package:cliq/modules/credentials/data/credential.service.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/value.extension.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';

final class ConnectionService {
  final ConnectionsRepository _connectionRepository;
  final ConnectionCredentialsRepository _connectionCredentialsRepository;

  final CredentialService _credentialService;

  const new(
    this._connectionRepository,
    this._connectionCredentialsRepository,
    this._credentialService,
  );

  Future<List<DbId>> findConnectionsByIdentityIds(Set<DbId> identityIds) async {
    return await _connectionRepository.db
        .findConnectionsByIdentityIds(identityIds.toList())
        .get()
        .then((connections) => connections.whereType<DbId>().toList());
  }

  Future<List<DbId>> findConnectionIdsByCredentialIds(
    Set<DbId> credentialIds,
  ) async {
    return await _connectionRepository.db
        .findConnectionIdsByCredentialIds(credentialIds.toList())
        .get()
        .then((connections) => connections.whereType<DbId>().toList());
  }

  Future<List<DbId>> findCredentialIdsByConnectionIds(
    Set<DbId> connectionIds,
  ) async {
    return await _connectionRepository.db
        .findCredentialIdsByConnectionIds(connectionIds.toList())
        .get()
        .then((credentials) => credentials.whereType<DbId>().toList());
  }

  Future<DbId?> findIdentityIdByConnectionId(DbId connectionId) {
    return _connectionRepository.db
        .findIdentityIdByConnectionId(connectionId)
        .getSingleOrNull();
  }

  Future<List<String>> findAllGroupNamesDistinct() async {
    return await _connectionRepository.db
        .findAllConnectionGroupNames()
        .get()
        .then((groups) => groups.whereType<String>().toList());
  }

  Future<List<ConnectionFull>> findAllByVaultId(DbId vaultId) async {
    return (await _connectionRepository.db.findAllConnectionFull(vaultId).get())
        .map(ConnectionFull.fromFindAllResult)
        .toList();
  }

  Stream<List<ConnectionFull>> watchAll() {
    // NOTE: drift does not correctly generate a nullable string from a IS NULL check, thus we just pass
    // an empty string here
    return _connectionRepository.db
        .findAllConnectionFull('')
        .watch()
        .map((c) => c.map(ConnectionFull.fromFindAllResult).toList());
  }

  Future<DbId> createConnection({
    required DbId vaultId,
    required String address,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String? label,
    required String? groupName,
    required int? port,
    required String? username,
    required ConnectionIcons? icon,
    required DbId? identityId,
    required TerminalTypography? terminalTypographyOverride,
    required String? terminalThemeOverrideId,
    required List<DbId> credentialIds,
  }) async {
    final usesDefaultThemeOverride =
        terminalThemeOverrideId == defaultTerminalColorTheme.id;
    final connection = await _connectionRepository.insert(
      ConnectionsCompanion.insert(
        vaultId: vaultId,
        label: (label ?? address).trim(),
        address: address.trim(),
        port: port ?? 22,
        groupName: Value.absentIfNull(groupName),
        icon: Value.absentIfNull(icon),
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        username: identityId != null
            ? const Value.absent()
            : Value.absentIfNull(username),
        identityId: Value.absentIfNull(identityId),
        terminalTypographyOverride: Value.absentIfNull(
          terminalTypographyOverride,
        ),
        terminalThemeOverrideId: Value.absentIfNull(
          usesDefaultThemeOverride ? null : terminalThemeOverrideId,
        ),
        usesDefaultThemeOverride: Value(usesDefaultThemeOverride),
      ),
    );
    await _credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: _connectionCredentialsRepository,
      builder: (id) => ConnectionCredentialsCompanion.insert(
        connectionId: connection.id,
        credentialId: id,
      ),
    );
    return connection.id;
  }

  Future<DbId> update(
    DbId connectionId, {
    required DbId? vaultId,
    required String? address,
    required Color? iconColor,
    required Color? iconBackgroundColor,
    required String? label,
    required String? groupName,
    required int? port,
    required String? username,
    required ConnectionIcons? icon,
    required DbId? identityId,
    required TerminalTypography? terminalTypographyOverride,
    required DbId? terminalThemeOverrideId,
    List<DbId>? newCredentialIds,
    ConnectionsCompanion? compareTo,
  }) async {
    final usesDefaultThemeOverride =
        terminalThemeOverrideId == defaultTerminalColorTheme.id;
    await _connectionRepository.updateById(
      connectionId,
      ConnectionsCompanion(
        vaultId: ValueExtension.absentIfNullOrSame(vaultId, compareTo?.vaultId),
        label: label != null
            ? ValueExtension.absentIfNullOrSame(label, compareTo?.label)
            : ValueExtension.absentIfNullOrSame(address, compareTo?.label),
        address: ValueExtension.absentIfNullOrSame(address, compareTo?.address),
        port: ValueExtension.absentIfNullOrSame(port, compareTo?.port),
        groupName: ValueExtension.absentIfSame(
          groupName,
          compareTo?.groupName.value,
        ),
        icon: ValueExtension.absentIfNullOrSame(icon, compareTo?.icon),
        iconColor: ValueExtension.absentIfNullOrSame(
          iconColor,
          compareTo?.iconColor,
        ),
        iconBackgroundColor: ValueExtension.absentIfNullOrSame(
          iconBackgroundColor,
          compareTo?.iconBackgroundColor,
        ),
        username: identityId != null
            ? const Value(null)
            : ValueExtension.absentIfSame(username, compareTo?.username.value),
        identityId: ValueExtension.absentIfSame(
          identityId,
          compareTo?.identityId.value,
        ),
        terminalTypographyOverride: ValueExtension.absentIfSame(
          terminalTypographyOverride,
          compareTo?.terminalTypographyOverride.value,
        ),
        terminalThemeOverrideId: ValueExtension.absentIfSame(
          usesDefaultThemeOverride ? null : terminalThemeOverrideId,
          compareTo?.terminalThemeOverrideId.value,
        ),
        usesDefaultThemeOverride: Value(usesDefaultThemeOverride),
      ),
    );

    if (newCredentialIds != null) {
      await _credentialService.insertAllWithRelation(
        newCredentialIds,
        relationRepository: _connectionCredentialsRepository,
        builder: (id) => ConnectionCredentialsCompanion.insert(
          connectionId: connectionId,
          credentialId: id,
        ),
      );
    }
    return connectionId;
  }

  Future<DbId> clearOverrides(DbId connectionId) async {
    await _connectionRepository.updateById(
      connectionId,
      const ConnectionsCompanion(
        terminalTypographyOverride: Value(null),
        terminalThemeOverrideId: Value(null),
        usesDefaultThemeOverride: Value(false),
      ),
    );
    return connectionId;
  }

  Future<int> createOrUpdate({
    required DbId id,
    required DbId vaultId,
    required String label,
    required String address,
    required int port,
    required DbId? identityId,
    required String? username,
    required String? groupName,
    required ConnectionIcons icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required TerminalTypography? terminalTypographyOverride,
    required String? terminalThemeOverrideId,
    required bool usesDefaultThemeOverride,
    required List<DbId> credentialIds,
  }) async {
    final result = await _connectionRepository.db.createOrUpdateConnection(
      id,
      vaultId,
      label,
      address,
      port,
      identityId,
      username,
      groupName,
      icon,
      iconColor,
      iconBackgroundColor,
      terminalTypographyOverride,
      terminalThemeOverrideId,
      usesDefaultThemeOverride,
    );

    await _credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: _connectionCredentialsRepository,
      builder: (cid) => ConnectionCredentialsCompanion.insert(
        connectionId: id,
        credentialId: cid,
      ),
    );

    return result;
  }

  Future<void> moveToVault(Set<DbId> ids, DbId vaultId) =>
      _connectionRepository.db.moveConnectionsByIds(vaultId, ids.toList());

  Future<void> deleteById(DbId id, List<DbId> credentialIds) async {
    await _credentialService.deleteByIds(credentialIds);
    return _connectionRepository.deleteById(id);
  }
}
