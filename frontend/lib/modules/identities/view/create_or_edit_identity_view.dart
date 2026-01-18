import 'dart:async';

import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/shared/extensions/value.extension.dart';
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
  final IdentitiesCompanion? current;
  final List<int>? currentCredentialIds;
  final bool isEdit;

  const CreateOrEditIdentityView.create({super.key})
    : current = null,
      currentCredentialIds = null,
      isEdit = false;

  CreateOrEditIdentityView.edit(IdentityFull identity, {super.key})
    : current = IdentitiesCompanion(
        id: Value(identity.id),
        label: Value(identity.label),
        username: Value(identity.username),
      ),
      currentCredentialIds = identity.credentialIds,
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final labelCtrl = useTextEditingController(text: current?.label.value);
    final usernameCtrl = useTextEditingController(
      text: current?.username.value,
    );

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      if (isEdit) {
        // TODO: handle credentials update in IdentityService
        await CliqDatabase.identitiesRepository.update(
          IdentitiesCompanion(
            label: ValueExtension.absentIfSame(
              labelCtrl.text,
              current?.label.value,
            ),
            username: ValueExtension.absentIfSame(
              usernameCtrl.text,
              current?.username.value,
            ),
          ),
        );
      } else {
        await CliqDatabase.identityService.createIdentity(
          IdentitiesCompanion(
            label: Value(labelCtrl.text),
            username: Value(usernameCtrl.text),
          ),
          // TODO: get credentials; use state to save credentials in form widget and only return ids here
          [],
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
                      ? CreateOrEditCredentialsForm.edit(currentCredentialIds)
                      : CreateOrEditCredentialsForm.create(),
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
