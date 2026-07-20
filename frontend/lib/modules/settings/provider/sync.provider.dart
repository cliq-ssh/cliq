import 'dart:convert';
import 'dart:typed_data';

import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/utils/password_cipher.dart';
import 'package:cliq_api/cliq_api.dart';
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
import '../model/settings_importer/cliq_settings_importer.dart';
import '../model/sync.state.dart';
import 'known_host.provider.dart';
import 'known_host_service.provider.dart';

final syncProvider = NotifierProvider(SyncProviderNotifier.new);

class SyncProviderNotifier extends Notifier<SyncState> {
  late final Logger _log = Logger('SyncProviderNotifier');

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

      final api = await _getDefaultClientBuilder(routeOptions).refresh(
        refreshToken: refreshToken,
        onRefreshTokenReceived: (token) =>
            StoreKey.syncRefreshToken.write(token),
      );

      state = state.copyWith(api: api);
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
    state = state.copyWith(api: api);
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
    await StoreKey.syncHost.delete();
    await StoreKey.syncDevicePrivateKey.delete();
    await StoreKey.syncDataEncryptionKey.delete();
    await StoreKey.syncRefreshToken.delete();
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

  /// Whether our current state is the latest version of the vault on the server.
  /// This is done by simply comparing the last updated timestamp of the vault on the server with the last updated
  /// timestamp of the vault in our local state.
  Future<bool> isLocalLatest() async {
    final remote = await state.api?.retrieveVaultLastUpdated();
    // this would only ever be the case if the user has never synced before, so we
    // can consider their local vault to be the latest version in that case
    if (remote == null) return true;
    final localMillis = await StoreKey.syncLastSynced.readAsync();
    final local = DateTime.fromMillisecondsSinceEpoch(localMillis!);

    // we apply the updatedAt time in [pullVault], which can be off a few places/milliseconds
    const millisecondsThreshold = 20;
    return ((local.millisecondsSinceEpoch - remote.millisecondsSinceEpoch)
                .abs() <
            millisecondsThreshold) ||
        local.isAfter(remote);
  }

  Future<void> sync() async {
    final latest = await isLocalLatest();
    if (!latest) {
      _log.finest(
        'Local vault is not the latest version, pulling from server...',
      );
      await pullVault();
    }
    _log.finest('Local vault is the latest version, pushing to server...');
    await pushVault();
  }

  Future<void> pullVault() async {
    if (state.api == null) return;
    final vault = await state.api!.retrieveVault();

    final json = await PasswordCipher.instance.decrypt(
      base64Decode(vault.configuration),
      StringUtils.hexToArray(
        (await StoreKey.syncDataEncryptionKey.readAsync())!,
      ),
    );

    final settings = AppSettings.tryFromJson(jsonDecode(utf8.decode(json)));
    if (settings == null) {
      throw StateError('Failed to parse vault configuration from server.');
    }
    import(settings, "1"); // TODO:
    StoreKey.syncLastSynced.write(vault.updatedAt.millisecondsSinceEpoch);
  }

  Future<bool> pushVault() async {
    if (state.api == null) {
      // we can't push if there are remote changes that we haven't pulled yet.
      return false;
    }

    final dek = await StoreKey.syncDataEncryptionKey.readAsync();
    if (dek == null) {
      // this should never happen, dek is set on login
      throw StateError('Data encryption key is missing, cannot push vault.');
    }

    final encrypted = await PasswordCipher.instance.encrypt(
      utf8.encode(jsonEncode((await export()).toJson())),
      StringUtils.hexToArray(dek),
    );

    await state.api!.upsertVault(configuration: base64Encode(encrypted));
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

  /// Imports the given [settings] into the vault with [vaultId].
  /// This method assumes that the settings have already been validated.
  Future<void> import(AppSettings settings, DbId vaultId) async {
    final connectionService = ref.read(connectionServiceProvider);
    final identityService = ref.read(identityServiceProvider);
    final knownHostService = ref.read(knownHostServiceProvider);
    final credentialService = ref.read(credentialServiceProvider);
    final keyService = ref.read(keyServiceProvider);

    final newKeyIds = <DbId, DbId>{}; // old id, new id
    final newCredentialIds = <DbId, DbId>{};
    final newIdentityIds = <DbId, DbId>{};

    for (final key in settings.keys ?? <KeysCompanion>[]) {
      final newId = await keyService.createKey(
        vaultId: vaultId,
        label: key.label.value,
        privateKey: key.privateKey.value,
        publicKey: key.publicKey.value,
        passphrase: key.passphrase.value,
      );
      newKeyIds[key.id.value] = newId;
    }

    for (final credential in settings.credentials ?? <CredentialsCompanion>[]) {
      final newId = await credentialService.createCredential(
        vaultId: vaultId,
        type: credential.type.value,
        data:
            credential.password.value ??
            newKeyIds[credential.keyId.value]!.toString(),
      );
      newCredentialIds[credential.id.value] = newId;
    }

    for (final identity in settings.identities ?? <IdentitiesCompanion>[]) {
      final newId = await identityService.createIdentity(
        vaultId: vaultId,
        label: identity.label.value,
        username: identity.username.value,
        credentialIds:
            settings.identitiesCredentialIds?[identity.id.value]
                ?.map((oldId) => newCredentialIds[oldId]!)
                .toList() ??
            [],
      );
      newIdentityIds[identity.id.value] = newId;
    }

    for (final connection in settings.connections ?? <ConnectionsCompanion>[]) {
      await connectionService.createConnection(
        vaultId: vaultId,
        address: connection.address.value,
        iconColor: connection.iconColor.value,
        iconBackgroundColor: connection.iconBackgroundColor.value,
        label: connection.label.value,
        groupName: connection.groupName.value,
        port: connection.port.value,
        username: connection.username.value,
        icon: connection.icon.value,
        identityId: connection.identityId.value != null
            ? newIdentityIds[connection.identityId.value!]
            : null,
        terminalTypographyOverride: connection.terminalTypographyOverride.value,
        terminalThemeOverrideId: connection.terminalThemeOverrideId.value,
        credentialIds:
            settings.connectionsCredentialIds?[connection.id.value]
                ?.map((oldId) => newCredentialIds[oldId]!)
                .toList() ??
            [],
      );
    }

    for (final knownHost in settings.knownHosts ?? <KnownHostsCompanion>[]) {
      await knownHostService.createKnownHost(
        vaultId: vaultId,
        host: knownHost.host.value,
        fingerprint: knownHost.hostKey.value,
      );
    }
  }

  /// Exports the current vault settings as an [AppSettings] object.
  Future<AppSettings> export() async {
    final connections = ref.read(connectionProvider);
    final identities = ref.read(identityProvider);
    final knownHosts = ref.read(knownHostProvider);
    final credentials = await ref.read(credentialServiceProvider).findAll();
    final keys = await ref.read(keyServiceProvider).findAll();
    final identitiesCredentialIds = identities.entities.asMap().map(
      (_, entity) => MapEntry(entity.id, entity.credentialIds),
    );
    final connectionsCredentialIds = connections.entities.asMap().map(
      (_, entity) => MapEntry(entity.id, entity.credentialIds),
    );

    return AppSettings(
      connections: connections.entities
          .map((e) => e.toCompanion(true))
          .toList(),
      identities: identities.entities.map((e) => e.toCompanion(true)).toList(),
      knownHosts: knownHosts.entities.map((e) => e.toCompanion(true)).toList(),
      credentials: credentials.map((e) => e.toCompanion(true)).toList(),
      keys: keys.map((e) => e.toCompanion(true)).toList(),
      identitiesCredentialIds: identitiesCredentialIds,
      connectionsCredentialIds: connectionsCredentialIds,
    );
  }

  CliqClientBuilder _getDefaultClientBuilder(RouteOptions routeOptions) {
    return CliqClientBuilder(routeOptions: routeOptions);
  }
}
