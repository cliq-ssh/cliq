import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cliq/modules/connections/provider/connection_service.provider.dart';
import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:cliq/modules/identities/provider/identity_service.provider.dart';
import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/cliq_settings_importer.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/modules/settings/model/sync.state.dart';
import 'package:cliq/modules/settings/provider/known_host_service.provider.dart';
import 'package:cliq/modules/settings/provider/terminal_theme_service.provider.dart';
import 'package:cliq/modules/vaults/provider/vault.provider.dart';
import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/entity_type.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/password_cipher.dart';
import 'package:cliq_api/cliq_api.dart' hide Vault;
import 'package:file_selector/file_selector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

final syncProvider = NotifierProvider(SyncProviderNotifier.new);

/// Returns true if the given [vaultId] has an error, false otherwise.
final vaultHasErrorProvider = Provider.family<bool, DbId>((ref, vaultId) {
  final vault = ref.watch(
    vaultProvider.select(
      (s) => s.entities.where((v) => v.id == vaultId).firstOrNull,
    ),
  );
  if (vault == null || vault.owner == null) return false;
  return ref.watch(syncProvider.select((s) => s.isError));
});

const kPullIntervalSeconds = 30;

class SyncProviderNotifier extends Notifier<SyncState> {
  late final Logger _log = Logger('SyncProviderNotifier');
  bool _isPulling = false;

  @override
  SyncState build() => const .initial();

  Future<ServerConfigurationResponse> retrieveConfig(
    RouteOptions routeOptions,
  ) async {
    // check if the URI is valid and the API is healthy
    final config = await CliqClient.retrieveConfiguration(routeOptions);
    _log.config(
      'Successfully connected to: ${routeOptions.hostUri}, config: $config',
    );
    state = state.copyWith(config: config);
    return config;
  }

  Future<void> attemptRecovery() async {
    // create local vault if not exists
    await ref.read(vaultProvider.notifier).findOrCreateVault();

    final routeOptions = await StoreKey.syncHost.readAsync();
    if (routeOptions == null ||
        (await StoreKey.syncRefreshToken.readAsync()) == null) {
      // we cannot recover due to missing route options or refresh token
      await deleteNonLocalVaults();
      return;
    }

    try {
      await retrieveConfig(routeOptions);

      final refreshToken = await StoreKey.syncRefreshToken.readAsync();
      if (refreshToken == null) return;

      final (api, expiresAt) = await _getDefaultClientBuilder(routeOptions)
          .refresh(
            refreshToken: refreshToken,
            onRefreshTokenReceived: (token) =>
                StoreKey.syncRefreshToken.write(token),
          );

      final durationTillRefresh = expiresAt.difference(DateTime.now());
      final refreshIn = durationTillRefresh - const Duration(seconds: 10);
      _log.info(
        'Successfully refreshed session, refreshing in ${durationTillRefresh.inSeconds} seconds',
      );

      state.refreshTimer?.cancel();
      // Schedule a timer to refresh the session 10 seconds before the refresh token expires
      final refreshTimer = Timer(refreshIn, () async {
        _log.info('Refresh token expired, attempting to refresh session...');
        await attemptRecovery();
      });

      state = state.copyWith(
        api: api,
        refreshTimer: refreshTimer,
        error: () => null,
      );
      await pullAllVaults();
      _startPullTimer();
    } on CliqException catch (e) {
      await Commons.showCliqException(e);
      state = state.copyWith(error: () => e.description);
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
      sessionName: 'cliq-client',
      // TODO: adjust session name
      onDataEncryptionKeyDecrypted: (dek) =>
          StoreKey.syncDataEncryptionKey.write(dek),
      onDevicePrivateKeyGenerated: (dpk) =>
          StoreKey.syncDevicePrivateKey.write(dpk),
      onRefreshTokenReceived: (token) => StoreKey.syncRefreshToken.write(token),
    );

    StoreKey.syncHost.write(routeOptions);
    state = state.copyWith(api: api, error: () => null);
    await pullAllVaults();
    _startPullTimer();
  }

  Future<void> register(
    RouteOptions routeOptions, {
    required String username,
    required String email,
    required Uint8List password,
  }) async {
    final config = await retrieveConfig(routeOptions);
    if (!config.localAuthProperties.registrationEnabled) {
      throw StateError('Registration is disabled on this server.');
    }
    await _getDefaultClientBuilder(routeOptions)
        .createUser(username: username, email: email, password: password);
  }

  Future<void> logout() async {
    await StoreKey.syncDevicePrivateKey.delete();
    await StoreKey.syncDataEncryptionKey.delete();
    await StoreKey.syncRefreshToken.delete();
    state.refreshTimer?.cancel();

    await deleteNonLocalVaults();

    state = const .initial();
  }

  Future<void> deleteNonLocalVaults() async {
    await ref.read(vaultProvider.notifier).initialized;

    final vaultService = ref.read(vaultServiceProvider);
    final vaults = ref.read(vaultProvider).entities;

    for (final vault in vaults.where((vault) => vault.owner != null)) {
      _log.info('Deleting vault ${vault.id}...');
      await vaultService.clearByVaultId(vault.id);
      await vaultService.deleteById(vault.id);
    }
  }

  Future<void> resendVerificationEmail(
    RouteOptions routeOptions, {
    required String email,
  }) async {
    await _getDefaultClientBuilder(routeOptions)
        .resendVerificationEmail(email: email);
  }

  Future<void> verifyRegistration(
    RouteOptions routeOptions, {
    required String verificationToken,
    required String email,
  }) async {
    await _getDefaultClientBuilder(routeOptions)
        .verifyEmail(email: email, verificationToken: verificationToken);
  }

  /// Whether we should pull the vault from the server because it
  /// seems to be newer than our local vault.
  Future<bool> shouldPull(String vaultId) async {
    final remoteMillisUtc = (await state.api?.retrieveVaultLastUpdated(
      id: vaultId,
    ))?.copyWith(microsecond: 0).toUtc();

    // this would only ever be the case if the user has never synced before, so we
    // can consider our local vault to be the latest version in that case
    if (remoteMillisUtc == null) return false;

    final vaultService = ref.read(vaultServiceProvider);
    final localMillis = await vaultService.getLastSyncedById(vaultId);
    if (localMillis == null) return true;

    final localMillisUTc = DateTime.fromMillisecondsSinceEpoch(
      localMillis.toInt(),
      isUtc: true,
    ).copyWith(microsecond: 0).toUtc();

    return remoteMillisUtc.isAfter(localMillisUTc);
  }

  /// Pulls the latest version from all vaults from the server and updates our local vault with it.
  /// Returns true if at least one vault was pulled and updated, false if it was not pulled because our local vault is
  /// already up to date.
  ///
  /// If  [ignoreShouldPull] is set to true, the vault is forcefully pulled.
  Future<bool> pullAllVaults({bool ignoreShouldPull = false}) async {
    try {
      final pulled = await _pullAllVaults(ignoreShouldPull: ignoreShouldPull);
      // reaching the server worked, so drop any stale error
      if (state.error != null) {
        state = state.copyWith(error: () => null);
      }
      return pulled;
    } catch (e, st) {
      _setError(e, st);
      rethrow;
    }
  }

  /// Pushes our local vault to the server, overwriting the server's vault with our local vault.
  /// This function should never be exposed to the end-user and only ever be used in combination with [pushVault].
  Future<bool> pushVault(DbId userVaultId) async {
    if (state.api == null) return false;
    final dek = await StoreKey.syncDataEncryptionKey.readAsync();
    if (dek == null) {
      // this should never happen, dek is set on login
      throw StateError('Data encryption key is missing, cannot push vault.');
    }

    final content = jsonEncode((await export(userVaultId)).toJson());

    final encrypted = await PasswordCipher.instance.encrypt(
      utf8.encode(content),
      StringUtils.hexToArray(dek),
    );

    await state.api!.upsertVault(
      id: userVaultId,
      configuration: base64Encode(encrypted),
    );
    final lastUpdated = await state.api!.retrieveVaultLastUpdated(
      id: userVaultId,
    );
    if (lastUpdated == null) {
      throw StateError(
        'Failed to retrieve last updated timestamp from server after pushing vault.',
      );
    }

    final vaultService = ref.read(vaultServiceProvider);
    await vaultService.updateLastSyncedById(userVaultId, lastUpdated);

    return true;
  }

  /// Pushes the locally mutated vault to the server.
  ///
  /// Callers use this after applying a local change. Pulling here would replace
  /// that mutation with the previous remote configuration.
  Future<bool> pullAndPushVault({DbId? vaultId}) async {
    if (state.api == null) return false;

    final userVault = vaultId == null
        ? await ref
              .read(vaultProvider.notifier)
              .findOrCreateUserVault(state.api!)
        : ref.read(vaultProvider.notifier).findById(vaultId);
    if (userVault == null) {
      throw StateError('Cannot sync missing vault $vaultId.');
    }

    return await pushVault(userVault.id);
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
      throw const LocalizedException(
        'settings_import_error.unrecognized_format',
      );
    }

    AppSettings? settings;
    if (parser is CliqSettingsImporter) {
      settings = await parser.tryParse(path, content, password: password);
    } else {
      settings = await parser.tryParse(path, content);
    }

    if (settings == null) {
      throw const LocalizedException('settings_import_error.parsing_failed');
    }
    return settings;
  }

  /// Validates the given [settings] for import and export operations.
  /// Returns true if the settings are valid, or false if they are not.
  bool validateSettings(AppSettings settings) {
    // check if any connection has an identity that is not in the identities list
    final identityIds =
        settings.identities?.map((e) => e.id.value).toSet() ?? <int>{};

    for (final connection in settings.connections ?? <ConnectionsCompanion>[]) {
      if (connection.identityId.value != null &&
          !identityIds.contains(connection.identityId.value)) {
        return false;
      }
    }
    return true;
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
    final terminalThemeService = ref.read(terminalThemeServiceProvider);
    final credentialService = ref.read(credentialServiceProvider);
    final keyService = ref.read(keyServiceProvider);
    final vaultService = ref.read(vaultServiceProvider);

    final themeIdRemap = <DbId, DbId>{};

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

      for (final theme
          in toImport.customTerminalThemes ??
              <CustomTerminalThemesCompanion>[]) {
        final existingId = await terminalThemeService.findIdOfMatchingTheme(
          theme,
        );
        if (existingId != null && existingId != theme.id.value) {
          // reuse theme instead of creating a duplicate
          themeIdRemap[theme.id.value] = existingId;
          continue;
        }

        await terminalThemeService.createOrUpdate(
          id: theme.id.value,
          name: theme.name.value,
          black: theme.black.value,
          red: theme.red.value,
          green: theme.green.value,
          yellow: theme.yellow.value,
          blue: theme.blue.value,
          purple: theme.purple.value,
          cyan: theme.cyan.value,
          white: theme.white.value,
          brightBlack: theme.brightBlack.value,
          brightRed: theme.brightRed.value,
          brightGreen: theme.brightGreen.value,
          brightYellow: theme.brightYellow.value,
          brightBlue: theme.brightBlue.value,
          brightPurple: theme.brightPurple.value,
          brightCyan: theme.brightCyan.value,
          brightWhite: theme.brightWhite.value,
          background: theme.background.value,
          foreground: theme.foreground.value,
          cursor: theme.cursor.value,
          cursorText: theme.cursorText.value,
          selectionForeground: theme.selectionForeground.value,
          selectionBackground: theme.selectionBackground.value,
        );
      }

      for (final connection
          in toImport.connections ?? <ConnectionsCompanion>[]) {
        final themeOverrideId = connection.terminalThemeOverrideId.value;

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
          terminalThemeOverrideId: themeOverrideId != null
              ? (themeIdRemap[themeOverrideId] ?? themeOverrideId)
              : null,
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
    final connectionService = ref.read(connectionServiceProvider);
    final identityService = ref.read(identityServiceProvider);
    final knownHostService = ref.read(knownHostServiceProvider);
    final terminalThemeService = ref.read(terminalThemeServiceProvider);
    final credentialService = ref.read(credentialServiceProvider);
    final keyService = ref.read(keyServiceProvider);

    return ref.read(databaseProvider).transaction(() async {
      final connections = await connectionService.findAllByVaultId(vaultId);
      final identities = await identityService.findAllByVaultId(vaultId);
      final knownHosts = await knownHostService.findAllByVaultId(vaultId);
      final credentials = await credentialService.findAll();
      final keys = await keyService.findAll();

      // Only export the themes actually referenced by this vault's connections
      final themeIds = connections
          .map((c) => c.terminalThemeOverrideId)
          .whereType<DbId>()
          .toSet();
      final terminalThemes = themeIds.isEmpty
          ? <CustomTerminalTheme>[]
          : await terminalThemeService.findByIds(
              themeIds.toList(growable: false),
            );

      final identitiesCredentialIds = {
        for (final e in identities) e.id: e.credentialIds,
      };
      final connectionsCredentialIds = {
        for (final e in connections) e.id: e.credentialIds,
      };

      return AppSettings(
        connections: connections.map((e) => e.toCompanion(true)).toList(),
        identities: identities.map((e) => e.toCompanion(true)).toList(),
        knownHosts: knownHosts.map((e) => e.toCompanion(true)).toList(),
        customTerminalThemes: terminalThemes
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
    });
  }

  Future<Map<EntityType, List<String>>> findNonLocalEntities() async {
    await ref.read(vaultProvider.notifier).initialized;

    final vaultIds = ref
        .read(vaultProvider)
        .entities
        .where((v) => v.owner != null)
        .map((v) => v.id)
        .toSet();

    final connectionService = ref.read(connectionServiceProvider);
    final identityService = ref.read(identityServiceProvider);
    final knownHostService = ref.read(knownHostServiceProvider);
    final keyService = ref.read(keyServiceProvider);

    final connections = <String>[];
    final identities = <String>[];
    final knownHosts = <String>[];

    for (final id in vaultIds) {
      connections.addAll(
        (await connectionService.findAllByVaultId(id)).map((e) => e.label),
      );
      identities.addAll(
        (await identityService.findAllByVaultId(id)).map((e) => e.label),
      );
      knownHosts.addAll(
        (await knownHostService.findAllByVaultId(id)).map((e) => e.host),
      );
    }

    final keys = (await keyService.findAll())
        .where((e) => vaultIds.contains(e.vaultId))
        .map((e) => e.label)
        .toList();

    return {
      if (connections.isNotEmpty) .connection: connections,
      if (identities.isNotEmpty) .identity: identities,
      if (keys.isNotEmpty) .key: keys,
      if (knownHosts.isNotEmpty) .knownHost: knownHosts,
    };
  }

  /// Internal implementation that pulls all of the vaults that needs to be pulled from the remote server.
  ///
  /// If  [ignoreShouldPull] is set to true, the vault is forcefully pulled.
  Future<bool> _pullAllVaults({bool ignoreShouldPull = false}) async {
    if (state.api == null) return false;
    final remoteVaults = await state.api!.listVaults();

    var pulled = false;
    for (final remote in remoteVaults) {
      final updated = await _pullVault(
        remote.id,
        ignoreShouldPull: ignoreShouldPull,
      );
      if (updated) {
        _log.info('Updated vault with id: ${remote.id}');
        pulled = true;
      }
    }

    return pulled;
  }

  /// Updates a single vault with the given id.
  ///
  /// If  [ignoreShouldPull] is set to true, the vault is forcefully pulled.
  Future<bool> _pullVault(String id, {bool ignoreShouldPull = false}) async {
    if (state.api == null) return false;
    if (!ignoreShouldPull && !(await shouldPull(id))) {
      return false;
    }

    final vault = await state.api!.retrieveVault(id: id);

    final dek = await StoreKey.syncDataEncryptionKey.readAsync();
    if (dek == null) {
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
    await import(settings, id, cleanImport: true);

    final vaultService = ref.read(vaultServiceProvider);

    await vaultService.updateLastSyncedById(id, DateTime.now());

    return true;
  }

  void _setError(Object e, StackTrace st) {
    _log.warning('Error during vault pull: $e', e, st);
    state = state.copyWith(error: () => e.toString());
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
          await pullAllVaults();
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
