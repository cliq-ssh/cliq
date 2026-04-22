import 'dart:convert';

import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/provider/known_host.provider.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/input_formatters.dart';
import 'package:cliq/shared/utils/password_cipher.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../../credentials/provider/credential_service.provider.dart';
import '../../keys/provider/key_service.provider.dart';

class ImportOrExportSettingsView extends StatefulHookConsumerWidget {
  final AppSettings? current;
  final bool isImport;

  const ImportOrExportSettingsView.export({super.key})
    : current = null,
      isImport = false;

  const ImportOrExportSettingsView.import({super.key, required this.current})
    : isImport = true;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImportOrExportSettingsViewState();
}

class _ImportOrExportSettingsViewState
    extends ConsumerState<ImportOrExportSettingsView> {
  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final settings = useState<AppSettings?>(widget.current);

    final connectionsTileController =
        useFMultiValueNotifier<(int, List<int>)>();
    final identitiesTileController = useFMultiValueNotifier<(int, List<int>)>();
    final knownHostsTileController = useFMultiValueNotifier<int>();
    final keysTileController = useFMultiValueNotifier<int>();

    final passwordController = useTextEditingController();
    final error = useState<String?>(null);

    useEffect(() {
      if (widget.isImport) return;

      // populate [settings] with current app settings for export
      final connections = ref.read(connectionProvider);
      final identities = ref.read(identityProvider);
      final knownHosts = ref.read(knownHostProvider);

      final credentials = ref.read(credentialServiceProvider).findAll();
      final keys = ref.read(keyServiceProvider).findAll();

      Future.wait([credentials, keys]).then((values) {
        final credentials = values[0] as List<Credential>;
        final keys = values[1] as List<Key>;

        settings.value = AppSettings(
          connections: connections.entities
              .map((e) => e.toCompanion(true))
              .toList(),
          identities: identities.entities
              .map((e) => e.toCompanion(true))
              .toList(),
          knownHosts: knownHosts.entities
              .map((e) => e.toCompanion(true))
              .toList(),
          credentials: credentials.map((e) => e.toCompanion(true)).toList(),
          keys: keys.map((e) => e.toCompanion(true)).toList(),
          identitiesCredentialIds: identities.entities.asMap().map(
            (_, entity) => MapEntry(entity.id, entity.credentialIds),
          ),
          connectionsCredentialIds: connections.entities.asMap().map(
            (_, entity) => MapEntry(entity.id, entity.credentialIds),
          ),
        );
      });

      return null;
    }, [widget.isImport]);

    onSave(int vaultId) async {
      // check if at least one is selected
      if (connectionsTileController.value.isEmpty &&
          identitiesTileController.value.isEmpty &&
          knownHostsTileController.value.isEmpty &&
          keysTileController.value.isEmpty) {
        error.value = 'settings.sync.import.selectAtLeastOneEntity';
        return;
      }

      final connections = settings.value?.connections
          ?.where(
            (c) => connectionsTileController.value.any(
              (id) => id.$1 == c.id.value,
            ),
          )
          .toList();

      final identities = settings.value?.identities
          ?.where(
            (i) =>
                identitiesTileController.value.any((id) => id.$1 == i.id.value),
          )
          .toList();

      getCredentialIds(Set<(int, List<int>)> selectedEntities) {
        final Map<int, List<int>> credentialIds = {};
        for (final entity in selectedEntities) {
          final id = entity.$1;
          final creds = entity.$2;
          credentialIds[id] = creds;
        }
        return credentialIds;
      }

      final selected = AppSettings(
        connections: connections,
        identities: identities,
        knownHosts: settings.value?.knownHosts
            ?.where((k) => knownHostsTileController.value.contains(k.id.value))
            .toList(),
        credentials: settings.value?.credentials,
        keys: settings.value?.keys
            ?.where((k) => keysTileController.value.contains(k.id.value))
            .toList(),
        connectionsCredentialIds: getCredentialIds(
          connectionsTileController.value,
        ),
        identitiesCredentialIds: getCredentialIds(
          identitiesTileController.value,
        ),
      );

      // validate settings
      final validationError = ref
          .read(syncProvider.notifier)
          .validateSettings(selected);
      if (validationError != null) {
        error.value = validationError;
        return;
      }
      error.value = null;

      if (widget.isImport) {
        ref.read(syncProvider.notifier).import(selected, vaultId);
      } else {
        final password = passwordController.text.trim();
        final encrypt = password.isNotEmpty;

        final text = jsonEncode(selected.toJson());

        // let user pick save location and export settings to file
        final success = await Commons.saveTextToFile(
          base64Encode(
            encrypt ? PasswordCipher.encrypt(text, password) : text.codeUnits,
          ),
          'cliq-export-${DateTime.now().millisecondsSinceEpoch}.txt',
        );

        if (!success) {
          return;
        }
      }

      if (!context.mounted) return;
      context.pop();
    }

    buildEntityTiles<T, ID>(
      FMultiValueNotifier<ID> controller,
      String label,
      List<T>? entities,
      ID Function(T) idSelector,
      String Function(T) titleBuilder, {
      String Function(T)? subtitleBuilder,
    }) {
      final toolbarTextStyle = context.theme.typography.xs.copyWith(
        fontWeight: .normal,
      );

      return FSelectTileGroup(
        label: Row(
          spacing: 4,
          children: [
            Text(label),
            const Spacer(),
            FTappable(
              onPress: () {
                if (entities == null) return;
                final allIds = entities.map(idSelector).toList();
                for (final id in allIds) {
                  controller.update(id, add: true);
                }
              },
              child: Text('Select All', style: toolbarTextStyle),
            ),
            Text('|', style: toolbarTextStyle),
            FTappable(
              onPress: () {
                if (entities == null) return;
                final allIds = entities.map(idSelector).toList();
                for (final id in allIds) {
                  controller.update(id, add: false);
                }
              },
              child: Text('Deselect All', style: toolbarTextStyle),
            ),
          ],
        ),
        control: .managed(controller: controller),
        children: [
          for (final entity in entities ?? <T>[])
            FSelectTile(
              title: Text(titleBuilder(entity)),
              subtitle: subtitleBuilder != null
                  ? Text(subtitleBuilder(entity))
                  : null,
              value: idSelector(entity),
            ),
        ],
      );
    }

    return CreateOrEditEntityView(
      onSave: (v) => onSave(v!),
      isEdit: widget.isImport,
      editLabel: 'Import',
      createLabel: 'Export...',
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: settings.value == null
              ? [Center(child: FCircularProgress())]
              : [
                  if (!widget.isImport)
                    FTextFormField.password(
                      control: .managed(controller: passwordController),
                      label: Text('Password (recommended)'),
                      description: Text(
                        'Encrypt exported settings with a password. Leave empty for no encryption.',
                      ),
                      inputFormatters: InputFormatters.password(),
                    ),

                  if (settings.value!.connections != null &&
                      settings.value!.connections!.isNotEmpty)
                    buildEntityTiles<ConnectionsCompanion, (int, List<int>)>(
                      connectionsTileController,
                      'Connections',
                      settings.value!.connections,
                      (c) => (
                        c.id.value,
                        settings.value!.connectionsCredentialIds![c.id.value]!,
                      ),
                      (c) => c.label.value,
                      subtitleBuilder: (c) =>
                          '${c.address.value}:${c.port.value}',
                    ),
                  if (settings.value!.identities != null &&
                      settings.value!.identities!.isNotEmpty)
                    buildEntityTiles<IdentitiesCompanion, (int, List<int>)>(
                      identitiesTileController,
                      'Identities',
                      settings.value!.identities,
                      (i) => (
                        i.id.value,
                        settings.value!.identitiesCredentialIds![i.id.value]!,
                      ),
                      (i) => i.label.value,
                      subtitleBuilder: (i) => i.username.value,
                    ),

                  if (settings.value!.keys != null &&
                      settings.value!.keys!.isNotEmpty)
                    buildEntityTiles<KeysCompanion, int>(
                      keysTileController,
                      'Keys',
                      settings.value!.keys,
                      (k) => k.id.value,
                      (k) => k.label.value,
                    ),

                  if (settings.value!.knownHosts != null &&
                      settings.value!.knownHosts!.isNotEmpty)
                    buildEntityTiles<KnownHostsCompanion, int>(
                      knownHostsTileController,
                      'Known Hosts',
                      settings.value!.knownHosts,
                      (k) => k.id.value,
                      (k) => k.host.value,
                    ),

                  if (error.value != null)
                    Text(
                      error.value!,
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.error,
                      ),
                    ),
                ],
        ),
      ),
    );
  }
}
