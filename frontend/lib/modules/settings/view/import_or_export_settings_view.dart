import 'dart:convert';

import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/provider/known_host.provider.dart';
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

class ImportOrExportSettingsView extends StatefulHookConsumerWidget {
  final AppSettings? current;
  final bool isImport;

  const ImportOrExportSettingsView.export({super.key})
    : current = null,
      isImport = false;

  const ImportOrExportSettingsView.import({super.key, required this.current})
    : isImport = true;

  bool get isExport => !isImport;

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

    final connectionsTileController = useFMultiValueNotifier<int>();
    final identitiesTileController = useFMultiValueNotifier<int>();
    final knownHostsTileController = useFMultiValueNotifier<int>();

    final passwordController = useTextEditingController();

    useEffect(() {
      if (widget.isImport) return;

      // populate [settings] with current app settings for export
      final connectionSettings = ref.read(connectionProvider);
      final identitySettings = ref.read(identityProvider);
      final knownHostSettings = ref.read(knownHostProvider);

      settings.value = AppSettings(
        connections: connectionSettings.entities
            .map((e) => e.toCompanion(true))
            .toList(),
        identities: identitySettings.entities
            .map((e) => e.toCompanion(true))
            .toList(),
        knownHosts: knownHostSettings.entities
            .map((e) => e.toCompanion(true))
            .toList(),
        credentials: null, // TODO
        keys: null, // TODO
      );

      return null;
    }, [widget.isImport]);

    onSave() async {
      // check if at least one is selected
      if (connectionsTileController.value.isEmpty &&
          identitiesTileController.value.isEmpty &&
          knownHostsTileController.value.isEmpty) {
        return;
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
        credentials: null, // TODO
        keys: null, // TODO
      );

      if (widget.isExport) {
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

    buildEntityTiles<T>(
      FMultiValueNotifier<int> controller,
      String label,
      List<T>? entities,
      int Function(T) idSelector,
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
      onSave: (_) => onSave(),
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
                  if (widget.isExport)
                    FTextFormField.password(
                      control: .managed(controller: passwordController),
                      label: Text('Password (recommended)'),
                      description: Text(
                        'Encrypt exported settings with a password. Leave empty for no encryption.',
                      ),
                      inputFormatters: InputFormatters.password(),
                    ),

                  buildEntityTiles<ConnectionsCompanion>(
                    connectionsTileController,
                    'Connections',
                    settings.value!.connections,
                    (c) => c.id.value,
                    (c) => c.label.value,
                    subtitleBuilder: (c) =>
                        '${c.address.value}:${c.port.value}',
                  ),
                  buildEntityTiles<IdentitiesCompanion>(
                    identitiesTileController,
                    'Identities',
                    settings.value!.identities,
                    (i) => i.id.value,
                    (i) => i.label.value,
                    subtitleBuilder: (i) => i.username.value,
                  ),
                  buildEntityTiles<KnownHostsCompanion>(
                    knownHostsTileController,
                    'Known Hosts',
                    settings.value!.knownHosts,
                    (k) => k.id.value,
                    (k) => k.host.value,
                  ),
                ],
        ),
      ),
    );
  }
}
