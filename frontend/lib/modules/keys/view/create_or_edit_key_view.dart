import 'dart:async';

import 'package:cliq/modules/keys/model/key_importer/key_importer.dart';
import 'package:cliq/shared/extensions/text_controller.extension.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide Key, Router;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';
import '../../../shared/utils/commons.dart';
import '../provider/key_service.provider.dart';

class CreateOrEditKeyView extends HookConsumerWidget {
  final KeysCompanion? current;
  final bool isEdit;
  final String? initialLabel;

  const CreateOrEditKeyView.create({super.key, this.initialLabel})
    : current = null,
      isEdit = false;

  CreateOrEditKeyView.edit(Key keyEntity, {super.key})
    : initialLabel = null,
      current = KeysCompanion(
        id: Value(keyEntity.id),
        vaultId: Value(keyEntity.vaultId),
        label: Value(keyEntity.label),
        privateKey: Value(keyEntity.privateKey),
        publicKey: Value(keyEntity.publicKey),
        passphrase: Value(keyEntity.passphrase),
      ),
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final labelCtrl = useTextEditingController(
      text: initialLabel ?? current?.label.value,
    );
    final privateKeyCtrl = useTextEditingController(
      text: current?.privateKey.value,
    );
    final publicKeyCtrl = useTextEditingController(
      text: current?.publicKey.value,
    );
    final passCtrl = useTextEditingController(text: current?.passphrase.value);

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave(int? vaultId) async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final keyService = ref.read(keyServiceProvider);
      final keyId = isEdit
          ? await keyService.update(
              current!.id.value,
              vaultId: vaultId,
              label: labelCtrl.textOrNull,
              privateKey: privateKeyCtrl.textOrNull,
              publicKey: publicKeyCtrl.textOrNull,
              passphrase: passCtrl.textOrNull,
              compareTo: current,
            )
          : await keyService.createKey(
              vaultId: vaultId!,
              label: labelCtrl.text,
              privateKey: privateKeyCtrl.text,
              publicKey: publicKeyCtrl.textOrNull,
              passphrase: passCtrl.text,
            );

      if (!context.mounted) return;
      context.pop((keyId, labelCtrl.text));
    }

    buildImportKeyButton(
      TextEditingController controller,
      KeyImporterType filter,
    ) {
      return FButton(
        variant: .ghost,
        prefix: Icon(LucideIcons.folderOpen),
        child: const Text('keys_import').tr(),
        onPress: () async {
          final keyFile = await openFile(
            acceptedTypeGroups: [Commons.keyGroup],
          );
          final content = await keyFile?.readAsString();

          final pem = await KeyImporter.parse(content, filter: filter);

          if (!context.mounted) return;
          if (pem == null) {
            Commons.showToast(
              'keys_import_error_format'.tr(),
              variant: .destructive,
              prefix: Icon(
                LucideIcons.triangleAlert,
                size: 20,
                color: context.theme.colors.destructive,
              ),
            );
            return;
          }

          controller.text = pem;
          showFToast(
            context: context,
            icon: Icon(LucideIcons.circleCheck),
            title: Text('keys_import_success').tr(),
          );
        },
      );
    }

    buildCopyButton(TextEditingController controller) {
      return FButton(
        variant: .ghost,
        prefix: Icon(LucideIcons.copy),
        child: Text('copy').tr(),
        onPress: () {
          Commons.copyToClipboard(context, controller.text);
        },
      );
    }

    return CreateOrEditEntityView(
      onSave: onSave,
      isEdit: isEdit,
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FTextFormField(
              control: .managed(controller: labelCtrl),
              label: const Text('keys_import_label').tr(),
              hint: 'keys_import_label_placeholder'.tr(),
              validator: Validators.nonEmpty,
            ),
            FTextFormField(
              control: .managed(controller: publicKeyCtrl),
              label: Row(
                crossAxisAlignment: .end,
                children: [
                  Text('keys_import_public_key').tr(),
                  const Spacer(),
                  buildImportKeyButton(publicKeyCtrl, .public),
                  buildCopyButton(publicKeyCtrl),
                ],
              ),
              maxLines: 1,
              hint: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQA...',
            ),
            FTextFormField(
              control: .managed(controller: privateKeyCtrl),
              label: Row(
                crossAxisAlignment: .end,
                children: [
                  Text('keys_import_private_key').tr(),
                  const Spacer(),
                  buildImportKeyButton(privateKeyCtrl, .private),
                  buildCopyButton(privateKeyCtrl),
                ],
              ),
              hint: 'keys_import_private_key_placeholder'.tr(),
              minLines: 8,
              maxLines: 8,
              validator: Validators.pem,
              autovalidateMode: .onUserInteraction,
            ),
            FTextFormField.password(
              control: .managed(controller: passCtrl),
              label: Text('keys_import_passphrase').tr(),
              maxLines: 1,
              autovalidateMode: .onUserInteraction,
            ),
          ],
        ),
      ),
    );
  }
}
