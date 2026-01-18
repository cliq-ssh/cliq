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
import '../../credentials/model/credential_type.dart';

class CreateOrEditIdentityView extends HookConsumerWidget {
  static const List<(CredentialType, String, IconData)> allowedCredentialTypes =
      [
        (.password, 'Password', LucideIcons.rectangleEllipsis),
        (.key, 'Key', LucideIcons.keyRound),
      ];

  final IdentitiesCompanion? current;
  final bool isEdit;

  const CreateOrEditIdentityView.create({super.key})
    : current = null,
      isEdit = false;

  CreateOrEditIdentityView.edit(IdentityFull identity, {super.key})
    : current = IdentitiesCompanion(
        id: Value(identity.id),
        label: Value(identity.label),
        username: Value(identity.username),
      ),
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final labelCtrl = useTextEditingController(text: current?.label.value);
    final usernameCtrl = useTextEditingController(
      text: current?.username.value,
    );

    final selectedCredentials =
        useState<Map<int, (CredentialType, String, String?)>>({});

    // TODO: Move credential handling to custom widget

    buildRemoveCredentialButton(int key) {
      return FButton.icon(
        style: FButtonStyle.destructive(),
        onPress: () {
          final updated = {...selectedCredentials.value};
          updated.remove(key);
          selectedCredentials.value = updated;
        },
        child: const Icon(LucideIcons.trash),
      );
    }

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      if (isEdit) {
        final comp = IdentitiesCompanion(
          label: ValueExtension.absentIfSame(
            labelCtrl.text,
            current?.label.value,
          ),
          username: ValueExtension.absentIfSame(
            usernameCtrl.text,
            current?.username.value,
          ),
        );
        await CliqDatabase.identitiesRepository.update(comp);
      } else {
        final insert = IdentitiesCompanion(
          label: Value(labelCtrl.text),
          username: Value(usernameCtrl.text),
        );
        await CliqDatabase.identityService.createIdentity(
          insert,
          selectedCredentials.value.values
              .map(
                (c) => CredentialsCompanion.insert(
                  type: c.$1,
                  keyId: Value.absentIfNull(null),
                  password: Value.absentIfNull(c.$3),
                ),
              )
              .toList(),
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

                  for (final c in selectedCredentials.value.entries)
                    if (c.value.$1 == .password)
                      FCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: .end,
                              children: [buildRemoveCredentialButton(c.key)],
                            ),
                            FTextFormField(
                              control: .lifted(
                                value: TextEditingValue(text: c.value.$2),
                                onChange: (v) => selectedCredentials.value = {
                                  ...selectedCredentials.value,
                                  c.key: (c.value.$1, v.text, c.value.$3),
                                },
                              ),
                              label: Text('Password'),
                              minLines: 1,
                              obscureText: true,
                              autovalidateMode: .onUserInteraction,
                            ),
                          ],
                        ),
                      )
                    else if (c.value.$1 == .key) ...[
                      FCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: .end,
                              children: [buildRemoveCredentialButton(c.key)],
                            ),
                            FTextFormField(
                              control: .lifted(
                                value: TextEditingValue(text: c.value.$2),
                                onChange: (v) => selectedCredentials.value = {
                                  ...selectedCredentials.value,
                                  c.key: (c.value.$1, v.text, c.value.$3),
                                },
                              ),
                              label: Text('PEM Key'),
                              hint: '-----BEGIN OPENSSH PRIVATE KEY-----',
                              minLines: 5,
                              maxLines: null,
                              autovalidateMode: .onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            FTextFormField(
                              control: .lifted(
                                value: TextEditingValue(text: c.value.$3 ?? ''),
                                onChange: (v) => selectedCredentials.value = {
                                  ...selectedCredentials.value,
                                  c.key: (c.value.$1, c.value.$2, v.text),
                                },
                              ),
                              label: Text('PEM Passphrase'),
                              obscureText: true,
                              maxLines: 1,
                              autovalidateMode: .onUserInteraction,
                            ),
                          ],
                        ),
                      ),
                    ],

                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      FPopoverMenu(
                        menu: [
                          FItemGroup(
                            children: [
                              for (final type in allowedCredentialTypes)
                                FItem(
                                  prefix: Icon(type.$3),
                                  title: Text(type.$2),
                                  onPress: () => selectedCredentials.value = {
                                    ...selectedCredentials.value,
                                    DateTime.now().millisecondsSinceEpoch: (
                                      type.$1,
                                      '',
                                      null,
                                    ),
                                  },
                                ),
                            ],
                          ),
                        ],
                        builder: (context, controller, child) {
                          return FButton(
                            style: FButtonStyle.secondary(),
                            prefix: const Icon(LucideIcons.plus),
                            onPress: controller.toggle,
                            child: const Text('Add Credential'),
                          );
                        },
                      ),
                    ],
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
