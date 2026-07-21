import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:cliq/shared/utils/password_cipher.dart';
import 'package:cliq_api/cliq_api.dart' hide Vault;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../shared/data/database.dart';
import '../../connections/provider/connection.provider.dart';
import '../../connections/provider/connection_service.provider.dart';
import '../../credentials/provider/credential_service.provider.dart';
import '../../identities/provider/identity.provider.dart';
import '../../identities/provider/identity_service.provider.dart';
import '../../keys/provider/key_service.provider.dart';
import '../../vaults/provider/vault.provider.dart';
import '../model/settings_importer/cliq_settings_importer.dart';
import '../model/sync.state.dart';
import 'known_host.provider.dart';
import 'known_host_service.provider.dart';

final syncProvider = NotifierProvider(SyncProviderNotifier.new);

const kPullIntervalSeconds = 30;

class SyncProviderNotifier extends Notifier<SyncState> {
  late final Logger _log = Logger('SyncProviderNotifier');
  bool _isPulling = false;

  @override
  SyncState build() => .initial();

  Future<void> retrieveConfig(RouteOptions routeOptions) async {
    // check if the URI is valid and the API is healthy
    final config = await CliqClient.retrieveConfiguration(routeOptions);
    _log.config(
      'Successfully connected to: ${routeOptions.hostUri}, config: $config',
    );
    state = state.copyWith(config: config);
  }

  Future<void> attemptRecovery() async {
    final routeOptions = await StoreKey.syncHost.readAsync();
    if (routeOptions == null) return;

    await retrieveConfig(routeOptions);

    try {
      final refreshToken = await StoreKey.syncRefreshToken.readAsync();
      if (refreshToken == null) return;

      final (api, expiresAt) = await _getDefaultClientBuilder(routeOptions)
          .refresh(
            refreshToken: refreshToken,
            onRefreshTokenReceived: (token) =>
                StoreKey.syncRefreshToken.write(token),
          );

      final durationTillRefresh = expiresAt.difference(DateTime.now());
      final refreshIn = durationTillRefresh - Duration(seconds: 10);
      _log.info(
        'Successfully refreshed session, refreshing in ${durationTillRefresh.inSeconds} seconds',
      );

      state.refreshTimer?.cancel();
      // Schedule a timer to refresh the session 10 seconds before the refresh token expires
      final refreshTimer = Timer(refreshIn, () async {
        _log.info('Refresh token expired, attempting to refresh session...');
        await attemptRecovery();
      });

      await ref.read(vaultProvider.notifier).findOrCreateUserVault(api);
      state = state.copyWith(api: api, refreshTimer: refreshTimer);
      await pullVault();
      _startPullTimer();
    } catch (e) {
      debugPrint('Failed to recover session: $e');
      await logout();
    }
  }

  Future<void> login(
    RouteOptions routeOptions, {
    required String email,
    required Uint8List password,
  }) async {
    final api = await _getDefaultClientBuilder(routeOptions).login(
      email: email,
      password: password,
      sessionName: 'cliq-client', // TODO: adjust session name
      onDataEncryptionKeyDecrypted: (dek) =>
          StoreKey.syncDataEncryptionKey.write(dek),
      onDevicePrivateKeyGenerated: (dpk) =>
          StoreKey.syncDevicePrivateKey.write(dpk),
      onRefreshTokenReceived: (token) => StoreKey.syncRefreshToken.write(token),
    );

    StoreKey.syncHost.write(routeOptions);
    await ref.read(vaultProvider.notifier).findOrCreateUserVault(api);
    state = state.copyWith(api: api);
    await pullVault();
    _startPullTimer();
  }

  Future<void> register(
    RouteOptions routeOptions, {
    required String username,
    required String email,
    required Uint8List password,
  }) async {
    await retrieveConfig(routeOptions);
    await _getDefaultClientBuilder(
      routeOptions,
    ).createUser(username: username, email: email, password: password);
  }

  Future<void> logout() async {
    await StoreKey.syncDevicePrivateKey.delete();
    await StoreKey.syncDataEncryptionKey.delete();
    await StoreKey.syncRefreshToken.delete();
    await StoreKey.syncLastUpdated.delete();
    state.refreshTimer?.cancel();

    final userVault = await ref
        .read(vaultProvider.notifier)
        .findOrCreateUserVault(state.api!);

    final vaultService = ref.read(vaultServiceProvider);
    await vaultService.clearByVaultId(userVault.id);
    await vaultService.deleteById(userVault.id);

    state = .initial();
  }

  Future<void> resendVerificationEmail(
    RouteOptions routeOptions, {
    required String email,
  }) async {
    await _getDefaultClientBuilder(
      routeOptions,
    ).resendVerificationEmail(email: email);
  }

  Future<void> verifyRegistration(
    RouteOptions routeOptions, {
    required String verificationToken,
    required String email,
  }) async {
    await _getDefaultClientBuilder(
      routeOptions,
    ).verifyEmail(email: email, verificationToken: verificationToken);
  }

  /// Whether we should pull the latest vault from the server because it
  /// seems to be newer than our local vault.
  Future<bool> shouldPull() async {
    final remote = (await state.api?.retrieveVaultLastUpdated())
        ?.copyWith(microsecond: 0) // drop microseconds for comparison
        .toUtc();
    // this would only ever be the case if the user has never synced before, so we
    // can consider our local vault to be the latest version in that case
    if (remote == null) return false;
    final localMillis = await StoreKey.syncLastUpdated.readAsync();
    final local = DateTime.fromMillisecondsSinceEpoch(
      localMillis!,
      isUtc: true,
    ).copyWith(microsecond: 0);

    return remote.isAfter(local);
  }

  /// Pulls the latest vault from the server and updates our local vault with it.
  /// Returns true if the vault was pulled and updated, false if it was not pulled because our local vault is
  /// already up to date.
  Future<bool> pullVault({Vault? userVaultOverride}) async {
    if (state.api == null) {
      throw StateError('Cannot pull vault, API is not initialized.');
    }
    if (!(await shouldPull())) {
      return false;
    }

    final userVault =
        userVaultOverride ??
        (await ref
            .read(vaultProvider.notifier)
            .findOrCreateUserVault(state.api!));
    final vault = await state.api!.retrieveVault();

    final dek = await StoreKey.syncDataEncryptionKey.readAsync();
    if (dek == null) {
      // this should never happen, dek is set on login
      throw StateError('Data encryption key is missing, cannot pull vault.');
    }

    final json = await PasswordCipher.instance.decrypt(
      base64Decode(vault.configuration),
      StringUtils.hexToArray(dek),
    );

    final settings = AppSettings.tryFromJson(jsonDecode(utf8.decode(json)));
    if (settings == null) {
      throw StateError('Failed to parse vault configuration from server.');
    }
    await import(settings, userVault.id, cleanImport: true);
    StoreKey.syncLastUpdated.write(vault.updatedAt.millisecondsSinceEpoch);
    return true;
  }

  /// Pulls the latest vault from the server so that we are in sync with the server and
  /// then pushes our local vault to the server.
  /// This is done to ensure that we don't overwrite any changes that may have been made on the server since our last sync.
  Future<bool> pullAndPushVault() async {
    if (state.api == null) {
      throw StateError('Cannot pull vault, API is not initialized.');
    }

    final userVault = await ref
        .read(vaultProvider.notifier)
        .findOrCreateUserVault(state.api!);

    await pullVault(userVaultOverride: userVault);

    final dek = await StoreKey.syncDataEncryptionKey.readAsync();
    if (dek == null) {
      // this should never happen, dek is set on login
      throw StateError('Data encryption key is missing, cannot push vault.');
    }

    final content = jsonEncode((await export(userVault.id)).toJson());

    final encrypted = await PasswordCipher.instance.encrypt(
      utf8.encode(content),
      StringUtils.hexToArray(dek),
    );

    await state.api!.upsertVault(configuration: base64Encode(encrypted));
    final lastUpdated = await state.api!.retrieveVaultLastUpdated();
    if (lastUpdated == null) {
      throw StateError(
        'Failed to retrieve last updated timestamp from server after pushing vault.',
      );
    }
    StoreKey.syncLastUpdated.write(lastUpdated.millisecondsSinceEpoch);
    return true;
  }

  /// Attempts to parse the given [file] as [AppSettings].
  /// If the file is null, not parsable, or fails for any reason, this method throws the i18n key of the error message.
  Future<AppSettings?> tryParseSettings(XFile? file, {String? password}) async {
    if (file == null) {
      return null;
    }
    final path = file.path;
    final content = await file.readAsString();

    final parser = await SettingsImporter.getParser(
      path,
      content,
      password: password,
    );
    if (parser == null) {
      throw LocalizedException('settings.import.error.unrecognizedFormat');
    }

    AppSettings? settings;
    if (parser is CliqSettingsImporter) {
      settings = await parser.tryParse(path, content, password: password);
    } else {
      settings = await parser.tryParse(path, content);
    }

    if (settings == null) {
      throw LocalizedException('settings.import.error.parsingFailed');
    }
    return settings;
  }

  /// Validates the given [settings] for import and export operations.
  /// Returns null if the settings are valid, or the i18n key of the error message if they are not.
  String? validateSettings(AppSettings settings) {
    // check if any connection has an identity that is not in the identities list
    final identityIds =
        settings.identities?.map((e) => e.id.value).toSet() ?? <int>{};

    for (final connection in settings.connections ?? <ConnectionsCompanion>[]) {
      if (connection.identityId.value != null &&
          !identityIds.contains(connection.identityId.value)) {
        return 'settings.import.error.missingIdentity';
      }
    }
    return null;
  }

  /// Imports the given [toImport] settings into the vault with [vaultId].
  /// This method assumes that the settings have already been validated.
  /// If [cleanImport] is true, the existing settings in the vault will be cleared before importing
  /// the new settings.
  Future<void> import(
    AppSettings toImport,
    DbId vaultId, {
    bool cleanImport = false,
  }) async {
    final connectionService = ref.read(connectionServiceProvider);
    final identityService = ref.read(identityServiceProvider);
    final knownHostService = ref.read(knownHostServiceProvider);
    final credentialService = ref.read(credentialServiceProvider);
    final keyService = ref.read(keyServiceProvider);
    final vaultService = ref.read(vaultServiceProvider);

    await ref.read(databaseProvider).transaction(() async {
      if (cleanImport) {
        await vaultService.clearByVaultId(vaultId);
      }

      for (final key in toImport.keys ?? <KeysCompanion>[]) {
        await keyService.createOrUpdate(
          id: key.id.value,
          vaultId: vaultId,
          label: key.label.value,
          privateKey: key.privateKey.value,
          publicKey: key.publicKey.value,
          passphrase: key.passphrase.value,
        );
      }

      for (final credential
          in toImport.credentials ?? <CredentialsCompanion>[]) {
        await credentialService.createOrUpdate(
          id: credential.id.value,
          vaultId: vaultId,
          type: credential.type.value,
          data: credential.password.value ?? credential.keyId.value!,
        );
      }

      for (final identity in toImport.identities ?? <IdentitiesCompanion>[]) {
        await identityService.createOrUpdate(
          id: identity.id.value,
          vaultId: vaultId,
          label: identity.label.value,
          username: identity.username.value,
          credentialIds:
              toImport.identitiesCredentialIds?[identity.id.value]?.toList() ??
              [],
        );
      }

      for (final connection
          in toImport.connections ?? <ConnectionsCompanion>[]) {
        await connectionService.createOrUpdate(
          id: connection.id.value,
          vaultId: vaultId,
          address: connection.address.value,
          iconColor: connection.iconColor.value,
          iconBackgroundColor: connection.iconBackgroundColor.value,
          label: connection.label.value,
          groupName: connection.groupName.value,
          port: connection.port.value,
          username: connection.username.value,
          icon: connection.icon.value,
          identityId: connection.identityId.value,
          terminalTypographyOverride:
              connection.terminalTypographyOverride.value,
          terminalThemeOverrideId: connection.terminalThemeOverrideId.value,
          usesDefaultThemeOverride: connection.usesDefaultThemeOverride.value,
          credentialIds:
              toImport.connectionsCredentialIds?[connection.id.value]
                  ?.toList() ??
              [],
        );
      }

      for (final knownHost in toImport.knownHosts ?? <KnownHostsCompanion>[]) {
        await knownHostService.createOrUpdate(
          id: knownHost.id.value,
          vaultId: vaultId,
          host: knownHost.host.value,
          fingerprint: knownHost.hostKey.value,
          createdAt: knownHost.createdAt.value,
        );
      }
    });
  }

  /// Exports the current vault settings as an [AppSettings] object.
  Future<AppSettings> export(DbId vaultId) async {
    final connections = ref.read(connectionProvider);
    final identities = ref.read(identityProvider);
    final knownHosts = ref.read(knownHostProvider);
    final credentials = await ref.read(credentialServiceProvider).findAll();
    final keys = await ref.read(keyServiceProvider).findAll();

    final identitiesCredentialIds = identities.entities
        .where((e) => e.vaultId == vaultId)
        .toList()
        .asMap()
        .map((_, entity) => MapEntry(entity.id, entity.credentialIds));
    final connectionsCredentialIds = connections.entities
        .where((e) => e.vaultId == vaultId)
        .toList()
        .asMap()
        .map((_, entity) => MapEntry(entity.id, entity.credentialIds));

    return AppSettings(
      connections: connections.entities
          .where((e) => e.vaultId == vaultId)
          .map((e) => e.toCompanion(true))
          .toList(),
      identities: identities.entities
          .where((e) => e.vaultId == vaultId)
          .map((e) => e.toCompanion(true))
          .toList(),
      knownHosts: knownHosts.entities
          .where((e) => e.vaultId == vaultId)
          .map((e) => e.toCompanion(true))
          .toList(),
      credentials: credentials
          .where((e) => e.vaultId == vaultId)
          .map((e) => e.toCompanion(true))
          .toList(),
      keys: keys
          .where((e) => e.vaultId == vaultId)
          .map((e) => e.toCompanion(true))
          .toList(),
      identitiesCredentialIds: identitiesCredentialIds,
      connectionsCredentialIds: connectionsCredentialIds,
    );
  }

  CliqClientBuilder _getDefaultClientBuilder(RouteOptions routeOptions) {
    return CliqClientBuilder(routeOptions: routeOptions);
  }

  void _startPullTimer() {
    state.pullTimer?.cancel();
    final pullTimer = Timer.periodic(
      const Duration(seconds: kPullIntervalSeconds),
      (_) async {
        if (_isPulling) return;
        _isPulling = true;
        try {
          await pullVault();
        } catch (e) {
          _log.warning('Periodic vault pull failed: $e');
        } finally {
          _isPulling = false;
        }
      },
    );
    state = state.copyWith(pullTimer: pullTimer);
  }
}
