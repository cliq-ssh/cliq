import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/model/connection_icons.dart';
import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/shared/extensions/text_controller.extension.dart';
import 'package:cliq/shared/ui/create_or_edit_credential_form.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
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
import 'package:easy_localization/easy_localization.dart';
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
import '../provider/connection_service.provider.dart';

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
  final List<DbId>? currentCredentialIds;
  final bool isEdit;

  const CreateOrEditConnectionView.create({super.key})
    : current = null,
      currentCredentialIds = null,
      isEdit = false;

  CreateOrEditConnectionView.edit(ConnectionFull connection, {super.key})
    : current = ConnectionsCompanion(
        id: Value(connection.id),
        vaultId: Value(connection.vaultId),
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
      ),
      currentCredentialIds = connection.credentialIds,
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionService = ref.read(connectionServiceProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final credentialsKey = useMemoized(
      () => GlobalKey<CreateOrEditCredentialsFormState>(),
    );
    final usernameFocusNode = useFocusNode();
    final selectedVaultId = useState<DbId?>(current?.vaultId.value);

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final defaultTerminalThemeId = useStore(.defaultTerminalThemeId);
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

    final selectedIcon = useState<ConnectionIcons>(
      current?.icon.value ?? ConnectionIcons.linux,
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
    final selectedTerminalThemeId = useState<DbId?>(
      current?.terminalThemeOverrideId.value,
    );
    final selectedIdentityId = useState<DbId?>(current?.identityId.value);

    final groups = useMemoizedFuture(() async {
      return await connectionService.findAllGroupNamesDistinct();
    }, []);

    Future<void> onSave(DbId? vaultId) async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final newCredentialIds = await credentialsKey.currentState?.save();
      // null is only returned when validation fails
      if (selectedIdentityId.value == null && newCredentialIds == null) return;

      final connectionId = isEdit
          ? await connectionService.update(
              current!.id.value,
              vaultId: vaultId,
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
          : await connectionService.createConnection(
              vaultId: vaultId!,
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
            defaultTerminalTypography.value.fontSize,
        fontFamily:
            fontFamily ??
            selectedTypographyOverride.value?.fontFamily ??
            defaultTerminalTypography.value.fontFamily,
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
              border: Border.all(color: context.theme.colors.border, width: 2),
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
                          hint: 'hosts_color_placeholder'.tr(),
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
                      tipBuilder: (_, _) => Text('hosts_brand_color'.tr()),
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
                        tipBuilder: (_, _) => Text('hosts_random_color'.tr()),
                        child: FButton.icon(
                          onPress: () => onChange?.call(
                            ColorExtension.generateRandom().toHex(),
                          ),
                          child: Icon(LucideIcons.dices),
                        ),
                      ),
                      if (bgColor != null)
                        FTooltip(
                          tipBuilder: (_, _) =>
                              Text('hosts_inverted_background_color'.tr()),
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
        title: Text('hosts_icon_and_color'.tr()),
        child: Padding(
          padding: const .symmetric(vertical: 20),
          child: Column(
            spacing: 8,
            crossAxisAlignment: .start,
            children: [
              FLabel(
                label: Text('hosts_icon_background_color'.tr()),
                layout: .vertical,
                child: buildColorPicker(
                  color: selectedIconBackgroundColor.value,
                  controller: iconBgColorCtrl,
                  isSelected: (c) => c == selectedIconBackgroundColor.value,
                  onChange: (hex) {
                    final result = ColorExtension.fromHex(hex);
                    if (result != null) {
                      selectedIconBackgroundColor.value = result;
                      if (iconBgColorCtrl.text != result.toHex()) {
                        iconBgColorCtrl.text = result.toHex();
                      }
                    }
                  },
                ),
              ),
              FLabel(
                label: Text('hosts_icon_color'.tr()),
                layout: .vertical,
                child: buildColorPicker(
                  color: selectedIconColor.value,
                  controller: iconColorCtrl,
                  isSelected: (c) => c == selectedIconColor.value,
                  onChange: (hex) {
                    final result = ColorExtension.fromHex(hex);
                    if (result != null) {
                      selectedIconColor.value = result;
                      if (iconColorCtrl.text != result.toHex()) {
                        iconColorCtrl.text = result.toHex();
                      }
                    }
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
                label: Text('hosts_icon'.tr()),
                layout: .vertical,
                child: Padding(
                  padding: const .symmetric(vertical: 16),
                  child: Column(
                    spacing: 20,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final icon in ConnectionIcons.values)
                            FTooltip(
                              tipBuilder: (_, _) => Text(icon.name),
                              child: FButton.icon(
                                variant: icon == selectedIcon.value
                                    ? .primary
                                    : .ghost,
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
        title: Text('hosts_terminal_appearance'.tr()),
        child: Padding(
          padding: const .symmetric(vertical: 20),
          child: Column(
            spacing: 20,
            children: [
              TerminalFontSizeSlider(
                selectedFontSize:
                    selectedTypographyOverride.value?.fontSize ??
                    defaultTerminalTypography.value.fontSize,
                onEnd: (value) => selectedTypographyOverride.value =
                    getEffectiveTypography(value, null),
              ),
              TerminalFontFamilySelect(
                selectedFontFamily:
                    selectedTypographyOverride.value?.fontFamily ??
                    defaultTerminalTypography.value.fontFamily,
                onChange: (selected) => selectedTypographyOverride.value =
                    getEffectiveTypography(null, selected),
              ),
              FSelect<DbId>.rich(
                format: (s) => terminalThemes.entities
                    .firstWhere(
                      (t) => t.id == s,
                      orElse: () => defaultTerminalColorTheme,
                    )
                    .name,
                control: .managed(
                  initial:
                      selectedTerminalThemeId.value ??
                      defaultTerminalThemeId.value,
                  onChange: (selected) {
                    if (selected == defaultTerminalThemeId.value) {
                      selected = null;
                    }

                    selectedTerminalThemeId.value = selected;
                  },
                ),
                label: Text('hosts_terminal_theme'.tr()),
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
        autovalidateMode: .onUserInteraction,
      );
    }

    return CreateOrEditEntityView(
      onSave: onSave,
      onVaultSelected: (vaultId) => selectedVaultId.value = vaultId,
      isEdit: isEdit,
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FTextFormField(
              control: .managed(controller: labelCtrl),
              label: Text('hosts_label'.tr()),
              hint: labelCtrl.text.isEmpty ? addressCtrl.text : null,
            ),

            FAutocomplete.text(
              control: .managed(controller: groupCtrl),
              label: Text('hosts_group'.tr()),
              clearable: (value) => value.text.isNotEmpty,
              contentEmptyBuilder: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: groupCtrl.text.isEmpty
                    ? Text('hosts_no_groups'.tr())
                    : Text('hosts_create_group'.tr(args: [groupCtrl.text])),
              ),
              contentErrorBuilder: (_, _, _, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('hosts_create_group'.tr(args: [groupCtrl.text])),
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
                    label: 'hosts_address'.tr(),
                    hint: 'hosts_address_placeholder'.tr(),
                    validator: (s) => Validators.address(context, s),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: buildTextField(
                    controller: portCtrl,
                    label: 'hosts_port'.tr(),
                    hint: 'hosts_port_placeholder'.tr(),
                    validator: (s) => Validators.port(context, s),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: FAutocomplete.textBuilder(
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
                        (v) => v.toLowerCase().contains(query.toLowerCase()),
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
                          ? 'hosts_username'.tr()
                          : 'hosts_identity'.tr(),
                    ),
                    minLines: 1,
                    validator: (s) {
                      // workaround as onChange does not trigger when selecting an autocomplete item
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        selectedIdentityId.value =
                            AutocompleteUtils.fromAutocompleteString(s!).$1;
                      });

                      final empty = Validators.nonEmpty(context, s);
                      if (empty != null) return empty;

                      return null;
                    },
                    autovalidateMode: .onUserInteraction,
                  ),
                ),
              ],
            ),

            if (selectedIdentityId.value == null &&
                selectedVaultId.value != null)
              isEdit
                  ? CreateOrEditCredentialsForm.edit(
                      key: credentialsKey,
                      vaultId: selectedVaultId.value!,
                      currentCredentialIds,
                    )
                  : CreateOrEditCredentialsForm.create(
                      key: credentialsKey,
                      vaultId: selectedVaultId.value!,
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
    );
  }
}
