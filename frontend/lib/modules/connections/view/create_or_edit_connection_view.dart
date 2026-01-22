import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/model/connection_icon.dart';
import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/shared/extensions/text_controller.extension.dart';
import 'package:cliq/shared/ui/create_or_edit_credential_form.dart';
import 'package:cliq/shared/ui/terminal_font_family_select.dart';
import 'package:cliq/shared/ui/terminal_font_size_slider.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/autocomplete_utils.dart';
import 'package:cliq/shared/utils/input_formatters.dart';
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

class CreateOrEditConnectionView extends HookConsumerWidget {
  static const List<(CredentialType, String, IconData)> allowedCredentialTypes =
      [
        (.password, 'Password', LucideIcons.rectangleEllipsis),
        (.key, 'Key', LucideIcons.keyRound),
      ];

  static const List<Color> _colorExamples = [
    Color(0xFFFFFFFF),
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  final ConnectionsCompanion? current;
  final List<int>? currentCredentialIds;
  final bool isEdit;

  const CreateOrEditConnectionView.create({super.key})
    : current = null,
      currentCredentialIds = null,
      isEdit = false;

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
        username: Value(
          connection.identityId == null
              ? connection.username
              : AutocompleteUtils.toAutocompleteString(
                  connection.identity!.id,
                  connection.identity!.label,
                ),
        ),
        identityId: Value(connection.identityId),
        terminalTypographyOverride: Value(
          connection.terminalTypographyOverride,
        ),
        terminalThemeOverrideId: Value(connection.terminalThemeOverrideId),
        isIconAutoDetect: Value(connection.isIconAutoDetect),
      ),
      currentCredentialIds = connection.credentialIds,
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final credentialsKey = useMemoized(
      () => GlobalKey<CreateOrEditCredentialsFormState>(),
    );
    final usernameFocusNode = useFocusNode();

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final identities = ref.watch(identityProvider);
    final terminalThemes = ref.watch(terminalThemeProvider);
    final expandedAccordionItem = useState<int?>(null);

    final labelCtrl = useTextEditingController(text: current?.label.value);
    final groupCtrl = useFAutocompleteController(
      text: current?.groupName.value,
    );
    final addressCtrl = useTextEditingController(text: current?.address.value);
    final portCtrl = useTextEditingController(
      text: current?.port.value.toString(),
    );
    final usernameCtrl = useFAutocompleteController(
      text: current?.username.value,
    );

    final iconColorCtrl = useTextEditingController(
      text: current?.iconColor.value.toHex(),
    );
    final iconBgColorCtrl = useTextEditingController(
      text: current?.iconBackgroundColor.value.toHex(),
    );

    final selectedIcon = useState<ConnectionIcon>(
      current?.icon.value ?? ConnectionIcon.linux,
    );
    final selectedIconColor = useState<Color>(
      current?.iconColor.value ?? Colors.white,
    );
    final selectedIconBackgroundColor = useState<Color>(
      current?.iconBackgroundColor.value ?? Colors.black,
    );
    final selectedTypographyOverride = useState<TerminalTypography?>(
      current?.terminalTypographyOverride.value,
    );
    final selectedTerminalThemeId = useState<int?>(
      current?.terminalThemeOverrideId.value,
    );
    final selectedIdentityId = useState<int?>(current?.identityId.value);

    final groups = useMemoizedFuture(() async {
      return await CliqDatabase.connectionService.findAllGroupNamesDistinct();
    }, []);

    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final newCredentialIds = await credentialsKey.currentState?.save();
      // null is only returned when validation fails
      if (selectedIdentityId.value == null && newCredentialIds == null) return;

      final connectionId = isEdit
          ? await CliqDatabase.connectionService.update(
              current!.id.value,
              address: addressCtrl.textOrNull,
              iconColor: selectedIconColor.value,
              iconBackgroundColor: selectedIconBackgroundColor.value,
              icon: selectedIcon.value,
              label: labelCtrl.textOrNull,
              groupName: groupCtrl.textOrNull,
              port: int.tryParse(portCtrl.text.trim()),
              username: usernameCtrl.textOrNull,
              identityId: selectedIdentityId.value,
              terminalTypographyOverride: selectedTypographyOverride.value,
              terminalThemeOverrideId: selectedTerminalThemeId.value,
              newCredentialIds: newCredentialIds,
              compareTo: current,
            )
          : await CliqDatabase.connectionService.createConnection(
              address: addressCtrl.text.trim(),
              iconColor: selectedIconColor.value,
              iconBackgroundColor: selectedIconBackgroundColor.value,
              icon: selectedIcon.value,
              label: labelCtrl.textOrNull,
              groupName: groupCtrl.textOrNull,
              port: int.tryParse(portCtrl.text.trim()),
              username: usernameCtrl.textOrNull,
              identityId: selectedIdentityId.value,
              terminalTypographyOverride: selectedTypographyOverride.value,
              terminalThemeOverrideId: selectedTerminalThemeId.value,
              credentialIds: newCredentialIds ?? [],
            );

      if (!context.mounted) return;
      context.pop(connectionId);
    }

    /// Gets the effective typography based on the provided [fontSize] and [fontFamily].
    /// If either parameter is null, it falls back to the current override or default values.
    /// If the resulting typography matches the default, the override is cleared.
    TerminalTypography? getEffectiveTypography(
      int? fontSize,
      String? fontFamily,
    ) {
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
        return null;
      }
      return typography;
    }

    /// Builds a color swatch for icon colors
    /// May also include a child widget to preview the icon with the colors.
    Widget buildColorSwatch({
      required Color color,
      required bool isSelected,
      Function(Color)? onTap,
    }) {
      return GestureDetector(
        onTap: () => onTap?.call(color),
        child: SizedBox.square(
          dimension: 36,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: .circular(8),
              border: Border.all(
                color: context.theme.colors.primaryForeground,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(
                    LucideIcons.check,
                    color: context.theme.colors.foreground,
                    size: 20,
                  )
                : null,
          ),
        ),
      );
    }

    Widget buildColorPicker({
      required Color color,
      required TextEditingController controller,
      required bool Function(Color) isSelected,
      void Function(String)? onChange,
      Widget? child,
      Color? bgColor,
    }) {
      return Padding(
        padding: const .symmetric(vertical: 16),
        child: Row(
          spacing: 32,
          crossAxisAlignment: .start,
          children: [
            SizedBox(
              width: 100,
              child: Column(
                spacing: 16,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: bgColor ?? color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: child,
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: FTextField(
                          control: .managed(
                            controller: controller,
                            onChange: (value) => onChange?.call(value.text),
                          ),
                          inputFormatters: InputFormatters.hex(),
                          hint: '#FFFFFF',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 8,
                crossAxisAlignment: .start,
                children: [
                  if (selectedIcon.value.brandColor != null)
                    FTooltip(
                      tipBuilder: (_, _) => Text('Brand Color'),
                      child: buildColorSwatch(
                        color: selectedIcon.value.brandColor!,
                        isSelected: isSelected.call(
                          selectedIcon.value.brandColor!,
                        ),
                        onTap: (c) => controller.text = c.toHex(),
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _colorExamples)
                        buildColorSwatch(
                          color: c,
                          isSelected: isSelected.call(c),
                          onTap: (c) => controller.text = c.toHex(),
                        ),
                      FTooltip(
                        tipBuilder: (_, _) => Text('Random'),
                        child: FButton.icon(
                          onPress: () => onChange?.call(
                            ColorExtension.generateRandom().toHex(),
                          ),
                          child: Icon(LucideIcons.dices),
                        ),
                      ),
                      if (bgColor != null)
                        FTooltip(
                          tipBuilder: (_, _) => Text('Inverted Background'),
                          child: FButton.icon(
                            onPress: () =>
                                onChange?.call(bgColor.invert().toHex()),
                            child: Icon(LucideIcons.squaresExclude),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    FAccordionItem buildIconItem() {
      return FAccordionItem(
        title: Text('Icon & Color'),
        child: Padding(
          padding: const .symmetric(vertical: 20),
          child: Column(
            spacing: 8,
            crossAxisAlignment: .start,
            children: [
              FLabel(
                label: Text('Background Color'),
                axis: .vertical,
                child: buildColorPicker(
                  color: selectedIconBackgroundColor.value,
                  controller: iconBgColorCtrl,
                  isSelected: (c) => c == selectedIconBackgroundColor.value,
                  onChange: (hex) {
                    final result = ColorExtension.fromHex(hex);
                    if (result != null) {
                      selectedIconBackgroundColor.value = result;
                    }
                  },
                ),
              ),
              FLabel(
                label: Text('Icon Color'),
                axis: .vertical,
                child: buildColorPicker(
                  color: selectedIconColor.value,
                  controller: iconColorCtrl,
                  isSelected: (c) => c == selectedIconColor.value,
                  onChange: (hex) {
                    final result = ColorExtension.fromHex(hex);
                    if (result != null) selectedIconColor.value = result;
                  },
                  child: Icon(
                    selectedIcon.value.iconData,
                    size: 48,
                    color: selectedIconColor.value,
                  ),
                  bgColor: selectedIconBackgroundColor.value,
                ),
              ),
              const SizedBox(height: 12),
              FLabel(
                label: Text('Icon'),
                axis: .vertical,
                child: Padding(
                  padding: const .symmetric(vertical: 16),
                  child: Column(
                    spacing: 20,
                    children: [
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
                ),
              ),
            ],
          ),
        ),
      );
    }

    FAccordionItem buildThemeItem() {
      return FAccordionItem(
        title: Text('Terminal Appearance'),
        child: Padding(
          padding: const .symmetric(vertical: 20),
          child: Column(
            spacing: 20,
            children: [
              TerminalFontSizeSlider(
                selectedFontSize:
                    selectedTypographyOverride.value?.fontSize ??
                    defaultTerminalTypography.value!.fontSize,
                onEnd: (value) => selectedTypographyOverride.value =
                    getEffectiveTypography(value, null),
              ),
              TerminalFontFamilySelect(
                selectedFontFamily:
                    selectedTypographyOverride.value?.fontFamily ??
                    defaultTerminalTypography.value!.fontFamily,
                onChange: (selected) => selectedTypographyOverride.value =
                    getEffectiveTypography(null, selected),
              ),
              FSelect<int>.rich(
                format: (s) => terminalThemes.entities
                    .firstWhere(
                      (t) => t.id == s,
                      orElse: () => defaultTerminalColorTheme,
                    )
                    .name,
                control: .managed(
                  initial:
                      selectedTerminalThemeId.value ??
                      terminalThemes.activeDefaultThemeId,
                ),
                label: Text('Terminal Theme'),
                onSaved: (selected) {
                  // if selected is default, set to null
                  if (selected == terminalThemes.activeDefaultThemeId) {
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
                    FSelectItem(value: theme.id, title: Text(theme.name)),
                ],
              ),
            ],
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
                    hint: labelCtrl.text.isEmpty ? addressCtrl.text : null,
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
                  Row(
                    spacing: 8,
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: buildTextField(
                          controller: addressCtrl,
                          label: 'Address',
                          hint: '127.0.0.1',
                          validator: Validators.address,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: buildTextField(
                          controller: portCtrl,
                          label: 'Port',
                          hint: '22',
                          validator: Validators.port,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: FAutocomplete.builder(
                          control: .managed(controller: usernameCtrl),
                          filter: (query) {
                            final values = identities.entities.map(
                              (i) => AutocompleteUtils.toAutocompleteString(
                                i.id,
                                i.label,
                              ),
                            );
                            if (query.isEmpty) {
                              return values;
                            }
                            return values.where(
                              (v) =>
                                  v.toLowerCase().contains(query.toLowerCase()),
                            );
                          },
                          contentBuilder: (context, text, suggestions) => [
                            for (final suggestion in suggestions)
                              FAutocompleteItem(
                                prefix: Icon(LucideIcons.users),
                                title: Text(
                                  AutocompleteUtils.fromAutocompleteString(
                                        suggestion,
                                      ).$2 ??
                                      suggestion,
                                ),
                                value: suggestion,
                              ),
                          ],
                          contentEmptyBuilder: (_, _) => SizedBox.shrink(),
                          focusNode: usernameFocusNode,
                          label: Text(
                            selectedIdentityId.value == null
                                ? 'Username'
                                : 'Identity',
                          ),
                          minLines: 1,
                          validator: (s) {
                            // workaround as onChange does not trigger when selecting an autocomplete item
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              selectedIdentityId.value =
                                  AutocompleteUtils.fromAutocompleteString(
                                    s!,
                                  ).$1;
                            });

                            final empty = Validators.nonEmpty(s);
                            if (empty != null) return empty;

                            return null;
                          },
                          autovalidateMode: .onUserInteraction,
                        ),
                      ),
                    ],
                  ),

                  if (selectedIdentityId.value == null)
                    isEdit
                        ? CreateOrEditCredentialsForm.edit(
                            key: credentialsKey,
                            currentCredentialIds,
                          )
                        : CreateOrEditCredentialsForm.create(
                            key: credentialsKey,
                          ),

                  FAccordion(
                    control: .lifted(
                      expanded: (i) => expandedAccordionItem.value == i,
                      onChange: (i, expanded) {
                        expandedAccordionItem.value = expanded ? i : null;
                      },
                    ),
                    children: [buildIconItem(), buildThemeItem()],
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
