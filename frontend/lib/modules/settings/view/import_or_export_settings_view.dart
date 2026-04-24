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
import 'package:lucide_flutter/lucide_flutter.dart';

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

    final connections = ref.read(connectionProvider);
    final identities = ref.read(identityProvider);
    final knownHosts = ref.read(knownHostProvider);

    final connectionsTileController = useFMultiValueNotifier<int>();
    final identitiesTileController = useFMultiValueNotifier<int>();
    final knownHostsTileController = useFMultiValueNotifier<int>();
    final keysTileController = useFMultiValueNotifier<int>();

    final relatedIdentityIds = useState<Set<int>>({});
    final relatedConnectionKeyIds = useState<Set<int>>({});
    final relatedIdentityKeyIds = useState<Set<int>>({});

    final passwordController = useTextEditingController();
    final error = useState<String?>(null);
    final showExportWarning = useState<bool>(false);

    useEffect(() {
      if (widget.isImport) return;

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

      if (!showExportWarning.value &&
          !widget.isImport &&
          (passwordController.text.trim().isEmpty)) {
        final hasSensitiveData =
            (settings.value?.connections?.isNotEmpty == true) ||
            (settings.value?.identities?.isNotEmpty == true) ||
            (settings.value?.keys?.isNotEmpty == true);

        if (hasSensitiveData) {
          showExportWarning.value = true;
          return;
        }
      }
      showExportWarning.value = false;

      Map<int, List<int>>? mapCredentialIds(
        Map<int, List<int>>? credentialIds,
        FMultiValueNotifier<int> controller,
      ) {
        return credentialIds?.map((id, credentialIds) {
          if (controller.value.contains(id)) {
            return MapEntry(id, credentialIds);
          } else {
            return MapEntry(id, []);
          }
        });
      }

      final selected = AppSettings(
        connections: settings.value?.connections
            ?.where((c) => connectionsTileController.value.contains(c.id.value))
            .toList(),
        identities: settings.value?.identities
            ?.where((i) => identitiesTileController.value.contains(i.id.value))
            .toList(),
        knownHosts: settings.value?.knownHosts
            ?.where((k) => knownHostsTileController.value.contains(k.id.value))
            .toList(),
        credentials: settings.value?.credentials,
        keys: settings.value?.keys
            ?.where((k) => keysTileController.value.contains(k.id.value))
            .toList(),
        connectionsCredentialIds: mapCredentialIds(
          settings.value?.connectionsCredentialIds,
          connectionsTileController,
        ),
        identitiesCredentialIds: mapCredentialIds(
          settings.value?.identitiesCredentialIds,
          identitiesTileController,
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

    getConnectionById(int id) {
      return settings.value?.connections?.firstWhere((c) => c.id.value == id);
    }

    getCredentialById(int id) {
      return settings.value?.credentials?.firstWhere((c) => c.id.value == id);
    }

    buildEntityTiles<T, ID>({
      required FMultiValueNotifier<ID> controller,
      required String label,
      required List<T>? entities,
      required ID Function(T) idSelector,
      required String Function(T) titleBuilder,
      bool Function(T)? isRelated,
      void Function(Set<ID>)? onChange,
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
        control: .managed(controller: controller, onChange: onChange),
        children: [
          for (final entity in entities ?? <T>[])
            FSelectTile(
              title: Text(titleBuilder(entity)),
              value: idSelector(entity),
              checkedIcon: isRelated?.call(entity) != true
                  ? const Icon(LucideIcons.check)
                  : const Icon(LucideIcons.link),
              enabled: isRelated?.call(entity) != true,
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

                  if (settings.value!.connections?.isNotEmpty == true)
                    buildEntityTiles<ConnectionsCompanion, int>(
                      controller: connectionsTileController,
                      label: 'Connections',
                      entities: settings.value!.connections,
                      idSelector: (c) => c.id.value,
                      titleBuilder: (c) => c.label.value,
                      onChange: (selectedIds) {
                        final newRelatedIdentityIds = <int>{};
                        final newRelatedKeyIds = <int>{};

                        for (final id in selectedIds) {
                          final connection = getConnectionById(id);
                          if (connection == null) continue;

                          // if connection has an identity, select it as well
                          if (connection.identityId.value != null) {
                            identitiesTileController.update(
                              connection.identityId.value!,
                              add: true,
                            );
                            newRelatedIdentityIds.add(
                              connection.identityId.value!,
                            );
                          }

                          // also select all credentials
                          final credentialIds =
                              settings.value!.connectionsCredentialIds?[id] ??
                              [];
                          for (final credentialId in credentialIds) {
                            final credential = getCredentialById(credentialId);
                            if (credential == null) continue;

                            final keyId = credential.keyId.value;
                            if (keyId != null) {
                              keysTileController.update(keyId, add: true);
                              newRelatedKeyIds.add(keyId);
                            }
                          }
                        }

                        relatedIdentityIds.value = newRelatedIdentityIds;
                        relatedConnectionKeyIds.value = newRelatedKeyIds;
                      },
                    ),

                  if (settings.value!.identities?.isNotEmpty == true)
                    buildEntityTiles<IdentitiesCompanion, int>(
                      controller: identitiesTileController,
                      label: 'Identities',
                      entities: settings.value!.identities,
                      idSelector: (i) => i.id.value,
                      titleBuilder: (i) => i.label.value,
                      isRelated: (i) =>
                          relatedIdentityIds.value.contains(i.id.value),
                      onChange: (selectedIds) {
                        final newRelatedKeyIds = <int>{};

                        for (final id in selectedIds) {
                          // also select all credentials
                          final credentialIds =
                              settings.value!.identitiesCredentialIds?[id] ??
                              [];
                          for (final credentialId in credentialIds) {
                            final credential = getCredentialById(credentialId);
                            if (credential == null) continue;

                            final keyId = credential.keyId.value;
                            if (keyId != null) {
                              keysTileController.update(keyId, add: true);
                              newRelatedKeyIds.add(keyId);
                            }
                          }
                        }

                        relatedIdentityKeyIds.value = newRelatedKeyIds;
                      },
                    ),

                  if (settings.value!.keys?.isNotEmpty == true)
                    buildEntityTiles<KeysCompanion, int>(
                      controller: keysTileController,
                      label: 'Keys',
                      entities: settings.value!.keys,
                      idSelector: (k) => k.id.value,
                      titleBuilder: (k) => k.label.value,
                      isRelated: (k) =>
                          relatedConnectionKeyIds.value.contains(k.id.value) ||
                          relatedIdentityKeyIds.value.contains(k.id.value),
                    ),

                  if (settings.value!.knownHosts?.isNotEmpty == true)
                    buildEntityTiles<KnownHostsCompanion, int>(
                      controller: knownHostsTileController,
                      label: 'Known Hosts',
                      entities: settings.value!.knownHosts,
                      idSelector: (k) => k.id.value,
                      titleBuilder: (k) => k.host.value,
                    ),

                  if (error.value != null)
                    Text(
                      error.value!,
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.error,
                      ),
                    ),

                  if (showExportWarning.value)
                    FCard(
                      style: .delta(
                        decoration: .boxDelta(
                          color: context.theme.colors.destructive.withValues(
                            alpha: 0.1,
                          ),
                          border: Border.all(
                            color: context.theme.colors.destructive.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(LucideIcons.triangleAlert),
                          Expanded(
                            child: Text(
                              'This export contains sensitive data, such as passwords and/or private keys. Setting an encryption password is highly recommended.',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
        ),
      ),
    );
  }
}
