import 'dart:ui';

import 'package:cliq/modules/connections/data/connection_credentials_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/value.extension.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';

import '../../credentials/data/credential_service.dart';
import '../model/connection_full.model.dart';
import '../model/connection_icon.dart';
import 'connections_repository.dart';

final class ConnectionService {
  final ConnectionsRepository _connectionRepository;
  final ConnectionCredentialsRepository _connectionCredentialsRepository;

  final CredentialService _credentialService;

  const ConnectionService(
    this._connectionRepository,
    this._connectionCredentialsRepository,
    this._credentialService,
  );

  Future<List<String>> findAllGroupNamesDistinct() async {
    return await _connectionRepository.db
        .findAllConnectionGroupNames()
        .get()
        .then((groups) => groups.whereType<String>().toList());
  }

  Stream<List<ConnectionFull>> watchAll() {
    return _connectionRepository.db.findAllConnectionFull().watch().map(
      (c) => c.map(ConnectionFull.fromFindAllResult).toList(),
    );
  }

  // TODO: label: Value(getEffectiveLabel()),
  //             icon: Value(selectedIcon.value),
  //             iconColor: Value(selectedIconColor.value),
  //             iconBackgroundColor: Value(selectedIconBackgroundColor.value),
  //             groupName: ValueExtension.absentIfNullOrEmpty(groupCtrl.text),
  //             address: addressCtrl.text.trim(),
  //             port: int.tryParse(portCtrl.text.trim()) ?? 22,
  //             username: selectedIdentityId.value != null
  //                 ? Value.absent()
  //                 : ValueExtension.absentIfNullOrEmpty(usernameCtrl.text),
  //             terminalTypographyOverride: ValueExtension.absentIfNullOrEmpty(
  //               selectedTypographyOverride.value,
  //             ),
  //             terminalThemeOverrideId: ValueExtension.absentIfNullOrEmpty(
  //               selectedTerminalThemeId.value,
  //             ),
  //             identityId: Value.absentIfNull(selectedIdentityId.value),

  Future<int> createConnection({
    required String address,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String? label,
    required String? groupName,
    required int? port,
    required String? username,
    required ConnectionIcon? icon,
    required int? identityId,
    required TerminalTypography? terminalTypographyOverride,
    required int? terminalThemeOverrideId,
    required List<int> credentialIds,
  }) async {
    final connectionId = await _connectionRepository.insert(
      ConnectionsCompanion.insert(
        label: label ?? address,
        address: address,
        port: port ?? 22,
        groupName: Value.absentIfNull(groupName),
        icon: Value.absentIfNull(icon),
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        username: identityId != null
            ? Value.absent()
            : Value.absentIfNull(username),
        identityId: Value.absentIfNull(identityId),
        terminalTypographyOverride: Value.absentIfNull(
          terminalTypographyOverride,
        ),
        terminalThemeOverrideId: Value.absentIfNull(terminalThemeOverrideId),
      ),
    );
    await _credentialService.insertAllWithRelation(
      credentialIds,
      relationRepository: _connectionCredentialsRepository,
      builder: (id) => ConnectionCredentialsCompanion.insert(
        connectionId: connectionId,
        credentialId: id,
      ),
    );
    return connectionId;
  }

  Future<int> update(
    int connectionId, {
    required List<int>? newCredentialIds,
    required String? address,
    required Color? iconColor,
    required Color? iconBackgroundColor,
    required String? label,
    required String? groupName,
    required int? port,
    required String? username,
    required ConnectionIcon? icon,
    required int? identityId,
    required TerminalTypography? terminalTypographyOverride,
    required int? terminalThemeOverrideId,
    ConnectionsCompanion? compareTo,
  }) async {
    await _connectionRepository.updateById(
      connectionId,
      ConnectionsCompanion(
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
            ? Value(null)
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
          terminalThemeOverrideId,
          compareTo?.terminalThemeOverrideId.value,
        ),
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

  Future<void> deleteById(int id, List<int> credentialIds) async {
    await _credentialService.deleteByIds(credentialIds);
    return _connectionRepository.deleteById(id);
  }
}
