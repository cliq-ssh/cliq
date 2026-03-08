import 'dart:async';

import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/shared/extensions/text_controller.extension.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';
import '../../../shared/ui/create_or_edit_credential_form.dart';

class CreateOrEditIdentityView extends HookConsumerWidget {
  final String? initialLabel;
  final IdentitiesCompanion? current;
  final List<int>? currentCredentialIds;
  final bool isEdit;

  const CreateOrEditIdentityView.create({super.key, this.initialLabel})
    : current = null,
      currentCredentialIds = null,
      isEdit = false;

  CreateOrEditIdentityView.edit(IdentityFull identity, {super.key})
    : initialLabel = null,
      current = IdentitiesCompanion(
        id: Value(identity.id),
        label: Value(identity.label),
        username: Value(identity.username),
      ),
      currentCredentialIds = identity.credentialIds,
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final credentialsKey = useMemoized(
      () => GlobalKey<CreateOrEditCredentialsFormState>(),
    );

    final labelCtrl = useTextEditingController(
      text: initialLabel ?? current?.label.value,
    );
    final usernameCtrl = useTextEditingController(
      text: current?.username.value,
    );

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final newCredentialIds = await credentialsKey.currentState?.save();
      // null is only returned when validation fails
      if (newCredentialIds == null) return;

      final identityId = isEdit
          ? await CliqDatabase.identityService.update(
              current!.id.value,
              label: labelCtrl.textOrNull,
              username: usernameCtrl.textOrNull,
              newCredentialIds: newCredentialIds,
              compareTo: current,
            )
          : await CliqDatabase.identityService.createIdentity(
              label: labelCtrl.text,
              username: usernameCtrl.text,
              credentialIds: newCredentialIds,
            );

      if (!context.mounted) return;
      context.pop((identityId, labelCtrl.text));
    }

    return FScaffold(
      child: SingleChildScrollView(
        padding: const .only(left: 32, right: 32, top: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton.icon(
                  variant: .outline,
                  onPress: () => context.pop(),
                  child: const Icon(LucideIcons.x),
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
                    hint: 'My Server',
                    validator: Validators.nonEmpty,
                  ),

                  FTextFormField(
                    control: .managed(controller: usernameCtrl),
                    label: const Text('Username'),
                    hint: 'root',
                    validator: Validators.nonEmpty,
                  ),

                  isEdit
                      ? CreateOrEditCredentialsForm.edit(
                          key: credentialsKey,
                          currentCredentialIds,
                        )
                      : CreateOrEditCredentialsForm.create(key: credentialsKey),
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
