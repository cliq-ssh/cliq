import 'package:cliq/modules/connections/model/connection_icon.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:cliq/shared/validators.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../data/credentials/credential_type.dart';
import '../../../data/database.dart';
import '../model/connection_color.dart';

class AddConnectionView extends StatefulHookConsumerWidget {
  const AddConnectionView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddConnectionPageState();
}

class _AddConnectionPageState extends ConsumerState<AddConnectionView> {
  static const List<(CredentialType, String, IconData)> allowedCredentialTypes =
      [
        (.password, 'Password', LucideIcons.rectangleEllipsis),
        (.key, 'Key', LucideIcons.keyRound),
      ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final labelController = useTextEditingController();
    final groupController = useFAutocompleteController();
    final addressController = useTextEditingController();
    final portController = useTextEditingController();
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final pemController = useTextEditingController();
    final pemPassphraseController = useTextEditingController();

    final selectedIcon = useState<ConnectionIcon>(.linux);
    final selectedColor = useState<Color>(ConnectionColor.red.color);
    final labelPlaceholder = useState('');
    final groups = useMemoizedFuture(() async {
      return await CliqDatabase.connectionService.findAllGroupNamesDistinct();
    }, []);
    final hasIdentities = useMemoizedFuture(() async {
      return await CliqDatabase.identityService.hasIdentities();
    }, []);

    final additionalCredentialType = useState<CredentialType?>(null);

    buildForm() {
      return Column(
        children: [
          Row(
            mainAxisAlignment: .end,
            children: [
              FButton(
                style: FButtonStyle.ghost(),
                prefix: Icon(LucideIcons.x),
                onPress: () => context.pop(),
                child: Text('Close'),
              ),
            ],
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: selectedColor.value,
              borderRadius: .circular(16),
            ),
            child: Icon(selectedIcon.value.iconData, size: 36),
          ),
          Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FTextFormField(
                  control: .managed(controller: labelController),
                  label: Text('Label'),
                  hint: labelPlaceholder.value,
                ),
                FAutocomplete(
                  control: .managed(controller: groupController),
                  label: Text('Group'),
                  clearable: (value) => value.text.isNotEmpty,
                  contentEmptyBuilder: (_, _) => Padding(
                    padding: const .symmetric(vertical: 12),
                    child: groupController.text.isEmpty
                        ? Text('No groups')
                        : Text('Create group "${groupController.text}"'),
                  ),
                  contentErrorBuilder: (_, _, _) => Padding(
                    padding: const .symmetric(vertical: 12),
                    child: Text('Create group "${groupController.text}"'),
                  ),
                  items: groups.on(
                    onData: (value) => value,
                    onLoading: () => [],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedIcon.value.brandColor != null)
                      GestureDetector(
                        onTap: () => selectedColor.value =
                            selectedIcon.value.brandColor!,
                        child: SizedBox.square(
                          dimension: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIcon.value.brandColor,
                              borderRadius: .circular(8),
                            ),
                            child: Icon(selectedIcon.value.iconData),
                          ),
                        ),
                      ),
                    for (final c in ConnectionColor.values)
                      GestureDetector(
                        onTap: () => selectedColor.value = c.color,
                        child: SizedBox.square(
                          dimension: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.color,
                              borderRadius: .circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final icon in ConnectionIcon.values)
                      FTooltip(
                        tipBuilder: (_, _) => Text(icon.name),
                        child: FButton.icon(
                          style: icon == selectedIcon.value
                              ? FButtonStyle.primary()
                              : FButtonStyle.ghost(),
                          onPress: () => selectedIcon.value = icon,
                          child: Icon(icon.iconData),
                        ),
                      ),
                  ],
                ),
                FTextFormField(
                  control: .managed(
                    controller: addressController,
                    onChange: (val) => labelPlaceholder.value = val.text,
                  ),
                  label: Text('Address'),
                  hint: '127.0.0.1',
                  validator: Validators.address,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                FTextFormField(
                  control: .managed(controller: portController),
                  label: Text('Port'),
                  hint: '22',
                  validator: Validators.port,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                FTextFormField(
                  control: .managed(controller: usernameController),
                  label: Text('Username'),
                  hint: 'root',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                if (additionalCredentialType.value == .password)
                  FTextFormField(
                    control: .managed(controller: passwordController),
                    label: Text('Password'),
                    obscureText: true,
                    maxLines: 1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                if (additionalCredentialType.value == .key) ...[
                  FTextFormField(
                    control: .managed(controller: pemController),
                    label: Text('PEM Key'),
                    hint: '-----BEGIN OPENSSH PRIVATE KEY-----',
                    minLines: 5,
                    maxLines: null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  FTextFormField(
                    control: .managed(controller: pemPassphraseController),
                    label: Text('PEM Passphrase'),
                    obscureText: true,
                    maxLines: 1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ],
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    hasIdentities.on(
                      defaultValue: SizedBox.shrink(),
                      onData: (hasIdentities) {
                        if (!hasIdentities) {
                          return SizedBox.shrink();
                        }
                        return FButton(
                          style: FButtonStyle.ghost(),
                          prefix: Icon(LucideIcons.keyRound),
                          onPress: null,
                          child: Text('Use Identity'),
                        );
                      },
                    ),
                    FPopoverMenu(
                      menu: [
                        FItemGroup(
                          children: [
                            for (final type in allowedCredentialTypes)
                              FItem(
                                prefix: Icon(type.$3),
                                title: Text(type.$2),
                                onPress: () =>
                                    additionalCredentialType.value = type.$1,
                              ),
                          ],
                        ),
                      ],
                      builder: (context, controller, child) {
                        return FButton(
                          style: FButtonStyle.ghost(),
                          prefix: Icon(LucideIcons.plus),
                          onPress: controller.toggle,
                          child: Text('Add Credential'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FButton(
              child: Text('Save Host'),
              onPress: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                int? credentialId;
                if (additionalCredentialType.value == .password) {
                  credentialId = await CliqDatabase.credentialsRepository
                      .insert(
                        CredentialsCompanion.insert(
                          type: .password,
                          data: passwordController.text,
                        ),
                      );
                } else if (additionalCredentialType.value == .key) {
                  final passphrase = pemPassphraseController.text.trim();
                  credentialId = await CliqDatabase.credentialsRepository
                      .insert(
                        CredentialsCompanion.insert(
                          type: .key,
                          data: pemController.text,
                          passphrase: Value.absentIfNull(
                            passphrase.isNotEmpty ? passphrase : null,
                          ),
                        ),
                      );
                }

                await CliqDatabase.connectionsRepository.insert(
                  ConnectionsCompanion.insert(
                    label: Value.absentIfNull(
                      labelController.text.trim().isNotEmpty
                          ? labelController.text.trim()
                          : null,
                    ),
                    icon: Value(selectedIcon.value),
                    color: Value(selectedColor.value.toHex()),
                    groupName: Value.absentIfNull(
                      groupController.text.trim().isNotEmpty
                          ? groupController.text.trim()
                          : null,
                    ),
                    address: addressController.text.trim(),
                    port: int.tryParse(portController.text.trim()) ?? 22,
                    username: Value.absentIfNull(
                      usernameController.text.trim().isNotEmpty
                          ? usernameController.text.trim()
                          : null,
                    ),
                    credentialId: Value.absentIfNull(credentialId),
                    identityId: Value.absent(), // TODO:
                  ),
                );

                // TODO: loading state, success toast
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ),
        ],
      );
    }

    return FScaffold(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: buildForm(),
      ),
    );
  }
}
