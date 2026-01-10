import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/model/connection_icon.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/extensions/value.extension.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:cliq_ui/cliq_ui.dart' show useMemoizedFuture;
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';
import '../../credentials/model/credential_type.dart';
import '../model/connection_color.dart';

class CreateOrEditConnectionView extends HookConsumerWidget {
  final String? currentLabel;
  final String? currentGroup;
  final String? currentAddress;
  final String? currentPort;
  final String? currentUsername;
  final String? currentPassword;
  final String? currentPem;
  final String? currentPemPassphrase;
  final ConnectionIcon? currentIcon;
  final Color? currentIconColor;
  final Color? currentIconBackgroundColor;
  final bool isUpdate;

  const CreateOrEditConnectionView.create({super.key})
    : currentLabel = null,
      currentGroup = null,
      currentAddress = null,
      currentPort = null,
      currentUsername = null,
      currentPassword = null,
      currentPem = null,
      currentPemPassphrase = null,
      currentIcon = null,
      currentIconColor = null,
      currentIconBackgroundColor = null,
      isUpdate = false;

  CreateOrEditConnectionView.edit(ConnectionFull connection, {super.key})
    : currentLabel = connection.label,
      currentGroup = connection.groupName,
      currentAddress = connection.address,
      currentPort = connection.port.toString(),
      currentUsername = connection.username,
      currentPassword = connection.credential?.type == .password
          ? connection.credential?.data
          : null,
      currentPem = connection.credential?.type == .key
          ? connection.credential?.data
          : null,
      currentPemPassphrase = connection.credential?.type == .key
          ? connection.credential?.passphrase
          : null,
      currentIcon = connection.icon,
      currentIconColor = connection.iconColor,
      currentIconBackgroundColor = connection.iconBackgroundColor,
      isUpdate = true;

  static const List<(CredentialType, String, IconData)> allowedCredentialTypes =
      [
        (.password, 'Password', LucideIcons.rectangleEllipsis),
        (.key, 'Key', LucideIcons.keyRound),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final labelCtrl = useTextEditingController(text: currentLabel);
    final groupCtrl = useFAutocompleteController(text: currentGroup);
    final addressCtrl = useTextEditingController(text: currentAddress);
    final portCtrl = useTextEditingController(text: currentPort);
    final usernameCtrl = useTextEditingController(text: currentUsername);
    final passwordCtrl = useTextEditingController(text: currentPassword);
    final pemCtrl = useTextEditingController(text: currentPem);
    final pemPassphraseCtrl = useTextEditingController(
      text: currentPemPassphrase,
    );

    final selectedIcon = useState<ConnectionIcon>(
      currentIcon ?? ConnectionIcon.linux,
    );
    final selectedIconColor = useState<Color>(
      currentIconColor ?? ConnectionColor.red.color,
    );
    final selectedIconBackgroundColor = useState<Color>(
      currentIconBackgroundColor ?? Colors.white,
    );

    final labelPlaceholder = useState<String>('');
    final additionalCredentialType = useState<CredentialType?>(null);

    final groups = useMemoizedFuture(() async {
      return await CliqDatabase.connectionService.findAllGroupNamesDistinct();
    }, []);
    final hasIdentities = useMemoizedFuture(() async {
      return await CliqDatabase.identityService.hasIdentities();
    }, []);

    buildColorSwatch({
      required Color foreground,
      required Color background,
      Widget? child,
    }) {
      final isSelected =
          selectedIconColor.value == foreground &&
          selectedIconBackgroundColor.value == background;
      return GestureDetector(
        onTap: () {
          selectedIconColor.value = foreground;
          selectedIconBackgroundColor.value = background;
        },
        child: SizedBox.square(
          dimension: 36,
          child: Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: context.theme.colors.foreground, width: 2)
                  : null,
            ),
            child: child,
          ),
        ),
      );
    }

    Widget buildTextField({
      required TextEditingController controller,
      required String label,
      String? hint,
      String? Function(String?)? validator,
      bool obscure = false,
      int? maxLines,
      int? minLines,
      void Function(TextEditingValue)? onChange,
    }) {
      return FTextFormField(
        control: .managed(controller: controller, onChange: onChange),
        label: Text(label),
        hint: hint,
        validator: validator,
        obscureText: obscure,
        maxLines: maxLines,
        minLines: minLines,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      );
    }

    Future<int?> maybeInsertCredential() async {
      if (additionalCredentialType.value == CredentialType.password) {
        return await CliqDatabase.credentialsRepository.insert(
          CredentialsCompanion.insert(type: .password, data: passwordCtrl.text),
        );
      } else if (additionalCredentialType.value == CredentialType.key) {
        final passphrase = pemPassphraseCtrl.text.trim();
        return await CliqDatabase.credentialsRepository.insert(
          CredentialsCompanion.insert(
            type: .key,
            data: pemCtrl.text,
            passphrase: Value.absentIfNull(
              passphrase.isNotEmpty ? passphrase : null,
            ),
          ),
        );
      }
      return null;
    }

    onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final credentialId = await maybeInsertCredential();

      if (isUpdate) {
        final comp = ConnectionsCompanion(
          label: ValueExtension.absentIfSame(labelCtrl.text, currentLabel),
          icon: ValueExtension.absentIfSame(selectedIcon.value, currentIcon),
          iconColor: ValueExtension.absentIfSame(
            selectedIconColor.value,
            currentIconColor,
          ),
          iconBackgroundColor: ValueExtension.absentIfSame(
            selectedIconBackgroundColor.value,
            currentIconBackgroundColor,
          ),
          groupName: ValueExtension.absentIfSame(groupCtrl.text, currentGroup),
          address: ValueExtension.absentIfSame(
            addressCtrl.text.trim(),
            currentAddress,
          ),
          port: ValueExtension.absentIfSame(
            int.tryParse(portCtrl.text.trim()) ?? 22,
            (currentPort != null) ? int.tryParse(currentPort!) : null,
          ),
          username: ValueExtension.absentIfSame(
            usernameCtrl.text,
            currentUsername,
          ),
          credentialId: ValueExtension.absentIfSame(credentialId, null),
          identityId: const Value.absent(), // TODO
        );

        await CliqDatabase.connectionsRepository.update(comp);
      } else {
        await CliqDatabase.connectionsRepository.insert(
          ConnectionsCompanion.insert(
            label: ValueExtension.absentIfNullOrEmpty(labelCtrl.text),
            icon: Value(selectedIcon.value),
            iconColor: Value(selectedIconColor.value),
            iconBackgroundColor: Value(selectedIconBackgroundColor.value),
            groupName: ValueExtension.absentIfNullOrEmpty(groupCtrl.text),
            address: addressCtrl.text.trim(),
            port: int.tryParse(portCtrl.text.trim()) ?? 22,
            username: ValueExtension.absentIfNullOrEmpty(usernameCtrl.text),
            credentialId: ValueExtension.absentIfNullOrEmpty(credentialId),
            identityId: const Value.absent(), // TODO
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: selectedIconBackgroundColor.value,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                selectedIcon.value.iconData,
                color: selectedIconColor.value,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: formKey,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FTextFormField(
                    control: .managed(controller: labelCtrl),
                    label: const Text('Label'),
                    hint: labelPlaceholder.value,
                  ),

                  FAutocomplete(
                    control: .managed(controller: groupCtrl),
                    label: const Text('Group'),
                    clearable: (value) => value.text.isNotEmpty,
                    contentEmptyBuilder: (_, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: groupCtrl.text.isEmpty
                          ? const Text('No groups')
                          : Text('Create group "${groupCtrl.text}"'),
                    ),
                    contentErrorBuilder: (_, _, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('Create group "${groupCtrl.text}"'),
                    ),
                    items: groups.on(onData: (v) => v, onLoading: () => []),
                  ),

                  Column(
                    spacing: 8,
                    children: [
                      if (selectedIcon.value.brandColor != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            buildColorSwatch(
                              foreground: Colors.white,
                              background: selectedIcon.value.brandColor!,
                              child: Icon(
                                selectedIcon.value.iconData,
                                color: Colors.white,
                              ),
                            ),
                            buildColorSwatch(
                              foreground: selectedIcon.value.brandColor!,
                              background: Colors.white,
                              child: Icon(
                                selectedIcon.value.iconData,
                                color: selectedIcon.value.brandColor!,
                              ),
                            ),
                          ],
                        ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in ConnectionColor.values)
                            buildColorSwatch(
                              foreground: Colors.white,
                              background: c.color,
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
                    ],
                  ),

                  buildTextField(
                    controller: addressCtrl,
                    label: 'Address',
                    hint: '127.0.0.1',
                    validator: Validators.address,
                    onChange: (val) => labelPlaceholder.value = val.text,
                  ),
                  buildTextField(
                    controller: portCtrl,
                    label: 'Port',
                    hint: '22',
                    validator: Validators.port,
                  ),
                  buildTextField(
                    controller: usernameCtrl,
                    label: 'Username',
                    hint: 'root',
                  ),

                  if (additionalCredentialType.value == CredentialType.password)
                    buildTextField(
                      controller: passwordCtrl,
                      label: 'Password',
                      obscure: true,
                      maxLines: 1,
                    ),
                  if (additionalCredentialType.value == CredentialType.key) ...[
                    buildTextField(
                      controller: pemCtrl,
                      label: 'PEM Key',
                      hint: '-----BEGIN OPENSSH PRIVATE KEY-----',
                      minLines: 5,
                      maxLines: null,
                    ),
                    buildTextField(
                      controller: pemPassphraseCtrl,
                      label: 'PEM Passphrase',
                      obscure: true,
                      maxLines: 1,
                    ),
                  ],

                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      hasIdentities.on(
                        defaultValue: const SizedBox.shrink(),
                        onData: (has) {
                          if (!has) return const SizedBox.shrink();
                          return FButton(
                            style: FButtonStyle.ghost(),
                            prefix: const Icon(LucideIcons.keyRound),
                            onPress: null,
                            child: const Text('Use Identity'),
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
              child: FButton(onPress: onSave, child: Text(isUpdate ? 'Update' : 'Save')),
            ),
          ],
        ),
      ),
    );
  }
}
