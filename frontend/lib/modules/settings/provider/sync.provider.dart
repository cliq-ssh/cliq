import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:file_selector/file_selector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  @override
  SyncState build() => .initial();

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
        privatePem: key.privatePem.value,
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
        hostKey: knownHost.hostKey.value,
      );
    }
  }
}
