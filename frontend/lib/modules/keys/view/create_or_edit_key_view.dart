import 'dart:async';

import 'package:cliq/shared/extensions/text_controller.extension.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
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
        privatePem: Value(keyEntity.privatePem),
        passphrase: Value(keyEntity.passphrase),
      ),
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final labelCtrl = useTextEditingController(
      text: initialLabel ?? current?.label.value,
    );
    final pemCtrl = useTextEditingController(text: current?.privatePem.value);
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
              privatePem: pemCtrl.textOrNull,
              passphrase: passCtrl.textOrNull,
              compareTo: current,
            )
          : await keyService.createKey(
              vaultId: vaultId!,
              label: labelCtrl.text,
              privatePem: pemCtrl.text,
              passphrase: passCtrl.text,
            );

      if (!context.mounted) return;
      context.pop((keyId, labelCtrl.text));
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
              label: const Text('Label'),
              hint: 'My Key',
              validator: Validators.nonEmpty,
            ),
            FTextFormField(
              control: .managed(controller: pemCtrl),
              label: Text('PEM Key'),
              hint: '-----BEGIN OPENSSH PRIVATE KEY-----',
              minLines: 5,
              maxLines: null,
              validator: Validators.nonEmpty,
              autovalidateMode: .onUserInteraction,
            ),
            FTextFormField(
              control: .managed(controller: passCtrl),
              label: Text('PEM Passphrase'),
              obscureText: true,
              maxLines: 1,
              autovalidateMode: .onUserInteraction,
            ),
          ],
        ),
      ),
    );
  }
}
