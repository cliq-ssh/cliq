import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/model/connection_icon.dart';
import 'package:cliq/modules/settings/ui/terminal_font_family_select.dart';
import 'package:cliq/modules/settings/ui/terminal_font_size_slider.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/extensions/value.extension.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:cliq_term/cliq_term.dart';
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
import '../../settings/provider/terminal_theme.provider.dart';
import '../model/connection_color.dart';

class CreateOrEditConnectionView extends HookConsumerWidget {
  static const List<(CredentialType, String, IconData)> allowedCredentialTypes =
      [
        (.password, 'Password', LucideIcons.rectangleEllipsis),
        (.key, 'Key', LucideIcons.keyRound),
      ];

  final ConnectionsCompanion? current;
  final String? currentPassword;
  final String? currentPem;
  final String? currentPemPassphrase;
  final bool isEdit;

  const CreateOrEditConnectionView.create({super.key})
    : current = null,
      currentPassword = null,
      currentPem = null,
      currentPemPassphrase = null,
      isEdit = false;

  /* TODO: cleanup:
    - move icon and color selection into accordion & into methods
    - add randomise button for icon colors
    - allow custom icon color

    e.g.:
    [ ] {randomise}
    #abcdef #abcdef
    [icon] [icon] [icon] [icon] [icon]
   */

  CreateOrEditConnectionView.edit(ConnectionFull connection, {super.key})
    : current = ConnectionsCompanion(
        id: Value(connection.id),
        label: Value(connection.label),
        icon: Value(connection.icon),
        iconColor: Value(connection.iconColor),
        iconBackgroundColor: Value(connection.iconBackgroundColor),
        groupName: Value(connection.groupName),
        address: Value(connection.address),
        port: Value(connection.port),
        username: Value(connection.username),
        credentialId: Value(connection.credentialId),
        identityId: Value(connection.identityId),
        terminalTypographyOverride: Value(
          connection.terminalTypographyOverride,
        ),
        terminalThemeOverrideId: Value(connection.terminalThemeOverrideId),
      ),
      currentPassword = connection.credential?.type == CredentialType.password
          ? connection.credential?.data
          : null,
      currentPem = connection.credential?.type == CredentialType.key
          ? connection.credential?.data
          : null,
      currentPemPassphrase = connection.credential?.type == CredentialType.key
          ? connection.credential?.passphrase
          : null,
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final terminalThemes = ref.watch(terminalThemeProvider);
    final isTerminalOverridesExpanded = useState(
      current?.terminalTypographyOverride.value != null,
    );

    final labelCtrl = useTextEditingController(text: current?.label.value);
    final groupCtrl = useFAutocompleteController(
      text: current?.groupName.value,
    );
    final addressCtrl = useTextEditingController(text: current?.address.value);
    final portCtrl = useTextEditingController(
      text: current?.port.value.toString(),
    );
    final usernameCtrl = useTextEditingController(
      text: current?.username.value,
    );
    final passwordCtrl = useTextEditingController(text: currentPassword);
    final pemCtrl = useTextEditingController(text: currentPem);
    final pemPassphraseCtrl = useTextEditingController(
      text: currentPemPassphrase,
    );

    final selectedIcon = useState<ConnectionIcon>(
      current?.icon.value ?? ConnectionIcon.linux,
    );
    final selectedIconColor = useState<Color>(
      current?.iconColor.value ?? ConnectionColor.red.color,
    );
    final selectedIconBackgroundColor = useState<Color>(
      current?.iconBackgroundColor.value ?? Colors.white,
    );
    final selectedTypographyOverride = useState<TerminalTypography?>(
      current?.terminalTypographyOverride.value,
    );
    final selectedTerminalThemeId = useState<int?>(
      current?.terminalThemeOverrideId.value,
    );

    final labelPlaceholder = useState<String>('');
    final additionalCredentialType = useState<CredentialType?>(null);

    final groups = useMemoizedFuture(() async {
      return await CliqDatabase.connectionService.findAllGroupNamesDistinct();
    }, []);
    final hasIdentities = useMemoizedFuture(() async {
      return await CliqDatabase.identityService.hasIdentities();
    }, []);

    /// Builds a color swatch for icon colors
    /// May also include a child widget to preview the icon with the colors.
    Widget buildColorSwatch({
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

    /// Builds a text field with the given parameters. Helpful for reducing boilerplate.
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

    /// Inserts the additional credential based on the selected [additionalCredentialType].
    /// Returns the inserted credential ID or null if no credential was added.
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

    /// Sets the effective typography based on the provided [fontSize] and [fontFamily].
    /// If either parameter is null, it falls back to the current override or default values.
    /// If the resulting typography matches the default, the override is cleared.
    setEffectiveTypography(int? fontSize, String? fontFamily) {
      final typography = TerminalTypography(
        fontSize:
            fontSize ??
            selectedTypographyOverride.value?.fontSize ??
            defaultTerminalTypography.value!.fontSize,
        fontFamily:
            fontFamily ??
            selectedTypographyOverride.value?.fontFamily ??
            defaultTerminalTypography.value!.fontFamily,
      );

      if (typography == defaultTerminalTypography.value) {
        selectedTypographyOverride.value = null;
      } else {
        selectedTypographyOverride.value = typography;
      }
    }

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final credentialId = await maybeInsertCredential();

      if (isEdit) {
        final comp = ConnectionsCompanion(
          label: ValueExtension.absentIfSame(
            labelCtrl.text,
            current?.label.value,
          ),
          icon: ValueExtension.absentIfSame(
            selectedIcon.value,
            current?.icon.value,
          ),
          iconColor: ValueExtension.absentIfSame(
            selectedIconColor.value,
            current?.iconColor.value,
          ),
          iconBackgroundColor: ValueExtension.absentIfSame(
            selectedIconBackgroundColor.value,
            current?.iconBackgroundColor.value,
          ),
          groupName: ValueExtension.absentIfSame(
            groupCtrl.text,
            current?.groupName.value,
          ),
          address: ValueExtension.absentIfSame(
            addressCtrl.text.trim(),
            current?.address.value,
          ),
          port: ValueExtension.absentIfSame(
            int.tryParse(portCtrl.text.trim()) ?? 22,
            current?.port.value,
          ),
          username: ValueExtension.absentIfSame(
            usernameCtrl.text,
            current?.username.value,
          ),
          credentialId: ValueExtension.absentIfSame(credentialId, null),
          identityId: const Value.absent(), // TODO
          terminalTypographyOverride: ValueExtension.absentIfSame(
            selectedTypographyOverride.value,
            current?.terminalTypographyOverride.value ??
                defaultTerminalTypography.value,
          ),
          terminalThemeOverrideId: ValueExtension.absentIfSame(
            selectedTerminalThemeId.value,
            current?.terminalThemeOverrideId.value ??
                terminalThemes.activeDefaultThemeId,
          ),
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
            terminalTypographyOverride: ValueExtension.absentIfNullOrEmpty(
              selectedTypographyOverride.value,
            ),
            terminalThemeOverrideId: ValueExtension.absentIfNullOrEmpty(
              selectedTerminalThemeId.value,
            ),
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
                      FAccordion(
                        control: .lifted(
                          expanded: (_) => isTerminalOverridesExpanded.value,
                          onChange: (_, expanded) =>
                              isTerminalOverridesExpanded.value = expanded,
                        ),
                        children: [
                          FAccordionItem(
                            title: Row(
                              mainAxisSize: .min,
                              children: [
                                Text('Theme Overrides'),
                                if (selectedTypographyOverride.value != null)
                                  Text(
                                    ' (changed)',
                                    style: context.theme.typography.xs.copyWith(
                                      color:
                                          context.theme.colors.mutedForeground,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                              ],
                            ),
                            child: Padding(
                              padding: const .symmetric(vertical: 20),
                              child: Column(
                                spacing: 20,
                                children: [
                                  TerminalFontSizeSlider(
                                    selectedFontSize:
                                        selectedTypographyOverride
                                            .value
                                            ?.fontSize ??
                                        defaultTerminalTypography
                                            .value!
                                            .fontSize,
                                    onEnd: (value) =>
                                        setEffectiveTypography(value, null),
                                  ),
                                  TerminalFontFamilySelect(
                                    selectedFontFamily:
                                        selectedTypographyOverride
                                            .value
                                            ?.fontFamily ??
                                        defaultTerminalTypography
                                            .value!
                                            .fontFamily,
                                    onChange: (selected) =>
                                        setEffectiveTypography(null, selected),
                                  ),
                                  FSelect<int>.rich(
                                    format: (s) {
                                      return terminalThemes.entities
                                          .firstWhere(
                                            (t) => t.id == s,
                                            orElse: () =>
                                                defaultTerminalColorTheme,
                                          )
                                          .name;
                                    },
                                    control: .managed(
                                      initial:
                                          selectedTerminalThemeId.value ??
                                          terminalThemes.activeDefaultThemeId,
                                    ),
                                    label: Text('Terminal Theme'),
                                    onSaved: (selected) {
                                      // if selected is default, set to null
                                      if (selected ==
                                          terminalThemes.activeDefaultThemeId) {
                                        selected = null;
                                        return;
                                      }

                                      selectedTerminalThemeId.value = selected;
                                    },
                                    children: [
                                      for (final theme in [
                                        defaultTerminalColorTheme,
                                        ...terminalThemes.entities,
                                      ])
                                        FSelectItem(
                                          value: theme.id,
                                          title: Text(theme.name),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
