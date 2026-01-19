import 'dart:async';

import 'package:cliq/shared/extensions/value.extension.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';

class CreateOrEditKeyView extends HookConsumerWidget {
  final KeysCompanion? current;
  final bool isEdit;

  const CreateOrEditKeyView.create({super.key})
    : current = null,
      isEdit = false;

  CreateOrEditKeyView.edit(Key keyEntity, {super.key})
    : current = KeysCompanion(
        id: Value(keyEntity.id),
        label: Value(keyEntity.label),
        privatePem: Value(keyEntity.privatePem),
        passphrase: Value(keyEntity.passphrase),
      ),
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final labelCtrl = useTextEditingController(text: current?.label.value);
    final pemCtrl = useTextEditingController(text: current?.privatePem.value);
    final passCtrl = useTextEditingController(text: current?.passphrase.value);

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      if (isEdit) {
        await CliqDatabase.keysRepository.update(
          KeysCompanion(
            label: ValueExtension.absentIfSame(
              labelCtrl.text,
              current?.label.value,
            ),
            privatePem: ValueExtension.absentIfSame(
              pemCtrl.text,
              current?.privatePem.value,
            ),
            passphrase: ValueExtension.absentIfSame(
              passCtrl.text,
              current?.passphrase.value,
            ),
          ),
        );
      } else {
        await CliqDatabase.keysRepository.insert(
          KeysCompanion.insert(
            label: labelCtrl.text,
            privatePem: pemCtrl.text,
            passphrase: ValueExtension.absentIfNullOrEmpty(passCtrl.text),
          ),
        );
      }

      if (!context.mounted) return;
      context.pop();
    }

    return FScaffold(
      child: SingleChildScrollView(
        padding: const .symmetric(horizontal: 32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  style: FButtonStyle.ghost(),
                  prefix: const Icon(LucideIcons.x),
                  onPress: () => context.pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Form(
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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: onSave,
                child: Text(isEdit ? 'Edit' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
