import 'dart:typed_data';

import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../shared/data/database.dart';
import '../../connections/provider/connection_service.provider.dart';
import '../../credentials/provider/credential_service.provider.dart';
import '../../identities/provider/identity_service.provider.dart';
import '../../keys/provider/key_service.provider.dart';
import '../model/settings_importer/cliq_settings_importer.dart';
import '../model/sync.state.dart';
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
    final api =
        await _getDefaultClientBuilder(
          routeOptions,
          // TODO: adjust session name
        ).login(
          email: email,
          password: password,
          sessionName: 'cliq-client',
          onDataEncryptionKeyDecrypted: (dek) =>
              StoreKey.syncDataEncryptionKey.write(dek),
          onDevicePrivateKeyGenerated: (dpk) =>
              StoreKey.syncDevicePrivateKey.write(dpk),
          onRefreshTokenReceived: (token) =>
              StoreKey.syncRefreshToken.write(token),
        );

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
  Future<void> import(AppSettings settings, int vaultId) async {
    final connectionService = ref.read(connectionServiceProvider);
    final identityService = ref.read(identityServiceProvider);
    final knownHostService = ref.read(knownHostServiceProvider);
    final credentialService = ref.read(credentialServiceProvider);
    final keyService = ref.read(keyServiceProvider);

    final newKeyIds = <int, int>{}; // old id, new id
    final newCredentialIds = <int, int>{};
    final newIdentityIds = <int, int>{};

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

  CliqClientBuilder _getDefaultClientBuilder(RouteOptions routeOptions) {
    return CliqClientBuilder(routeOptions: routeOptions);
  }
}
