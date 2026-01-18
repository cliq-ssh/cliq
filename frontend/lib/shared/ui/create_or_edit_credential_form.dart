import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../modules/credentials/model/credential_type.dart';

/// Helper class to define allowed credential types and their properties.
enum _AllowedCredentialType {
  password(
    type: .password,
    label: 'Password',
    icon: LucideIcons.rectangleEllipsis,
    singleInstance: true,
  ),
  key(type: .key, label: 'Key', icon: LucideIcons.keyRound);

  final CredentialType type;
  final String label;
  final IconData icon;
  final bool singleInstance;

  const _AllowedCredentialType({
    required this.type,
    required this.label,
    required this.icon,
    this.singleInstance = false,
  });
}

class CreateOrEditCredentialsForm extends HookConsumerWidget {
  final List<int>? current;
  final bool isEdit;

  const CreateOrEditCredentialsForm.create({super.key})
    : current = null,
      isEdit = false;

  const CreateOrEditCredentialsForm.edit(this.current, {super.key})
    : isEdit = true;

  // TODO: maybe make this stateful? add save method to insert/update credentials & return their IDs

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCredentials =
        useState<Map<int, (CredentialType, String, String?)>>({});

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

    return Column(
      spacing: 16,
      children: [
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
                    for (final allowed in _AllowedCredentialType.values)
                      if (!allowed.singleInstance ||
                          !selectedCredentials.value.values.any(
                            (e) => e.$1 == allowed.type,
                          ))
                        FItem(
                          prefix: Icon(allowed.icon),
                          title: Text(allowed.label),
                          onPress: () => selectedCredentials.value = {
                            ...selectedCredentials.value,
                            DateTime.now().millisecondsSinceEpoch: (
                              allowed.type,
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
    );
  }
}
