import 'dart:async';

import 'package:cliq/modules/settings/provider/terminal_theme_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/input_formatters.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CreateOrEditTerminalThemeSheet extends HookConsumerWidget {
  final CustomTerminalThemesCompanion? current;
  final bool isEdit;

  const new create({super.key}) : current = null, isEdit = false;

  new edit(CustomTerminalTheme themeEntity, {super.key})
    : current = CustomTerminalThemesCompanion(
        id: Value(themeEntity.id),
        name: Value(themeEntity.name),
        black: Value(themeEntity.black),
        red: Value(themeEntity.red),
        green: Value(themeEntity.green),
        yellow: Value(themeEntity.yellow),
        blue: Value(themeEntity.blue),
        purple: Value(themeEntity.purple),
        cyan: Value(themeEntity.cyan),
        white: Value(themeEntity.white),
        brightBlack: Value(themeEntity.brightBlack),
        brightRed: Value(themeEntity.brightRed),
        brightGreen: Value(themeEntity.brightGreen),
        brightYellow: Value(themeEntity.brightYellow),
        brightBlue: Value(themeEntity.brightBlue),
        brightPurple: Value(themeEntity.brightPurple),
        brightCyan: Value(themeEntity.brightCyan),
        brightWhite: Value(themeEntity.brightWhite),
        foreground: Value(themeEntity.foreground),
        background: Value(themeEntity.background),
        cursor: Value(themeEntity.cursor),
        cursorText: Value(themeEntity.cursorText),
        selectionBackground: Value(themeEntity.selectionBackground),
        selectionForeground: Value(themeEntity.selectionForeground),
      ),
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameCtrl = useTextEditingController(text: current?.name.value);
    final blackCtrl = useTextEditingController(
      text: current?.black.value.toHex(),
    );
    final redCtrl = useTextEditingController(text: current?.red.value.toHex());
    final greenCtrl = useTextEditingController(
      text: current?.green.value.toHex(),
    );
    final yellowCtrl = useTextEditingController(
      text: current?.yellow.value.toHex(),
    );
    final blueCtrl = useTextEditingController(
      text: current?.blue.value.toHex(),
    );
    final purpleCtrl = useTextEditingController(
      text: current?.purple.value.toHex(),
    );
    final cyanCtrl = useTextEditingController(
      text: current?.cyan.value.toHex(),
    );
    final whiteCtrl = useTextEditingController(
      text: current?.white.value.toHex(),
    );
    final brightBlackCtrl = useTextEditingController(
      text: current?.brightBlack.value.toHex(),
    );
    final brightRedCtrl = useTextEditingController(
      text: current?.brightRed.value.toHex(),
    );
    final brightGreenCtrl = useTextEditingController(
      text: current?.brightGreen.value.toHex(),
    );
    final brightYellowCtrl = useTextEditingController(
      text: current?.brightYellow.value.toHex(),
    );
    final brightBlueCtrl = useTextEditingController(
      text: current?.brightBlue.value.toHex(),
    );
    final brightPurpleCtrl = useTextEditingController(
      text: current?.brightPurple.value.toHex(),
    );
    final brightCyanCtrl = useTextEditingController(
      text: current?.brightCyan.value.toHex(),
    );
    final brightWhiteCtrl = useTextEditingController(
      text: current?.brightWhite.value.toHex(),
    );
    final foregroundCtrl = useTextEditingController(
      text: current?.foreground.value.toHex(),
    );
    final backgroundCtrl = useTextEditingController(
      text: current?.background.value.toHex(),
    );
    final cursorCtrl = useTextEditingController(
      text: current?.cursor.value.toHex(),
    );
    final cursorTextCtrl = useTextEditingController(
      text: current?.cursorText.value.toHex(),
    );
    final selectionBackgroundCtrl = useTextEditingController(
      text: current?.selectionBackground.value.toHex(),
    );
    final selectionForegroundCtrl = useTextEditingController(
      text: current?.selectionForeground.value.toHex(),
    );

    /// Handles the save action for the form.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final name = nameCtrl.text.trim();

      final black = ColorExtension.fromHex(blackCtrl.text)!;
      final red = ColorExtension.fromHex(redCtrl.text)!;
      final green = ColorExtension.fromHex(greenCtrl.text)!;
      final yellow = ColorExtension.fromHex(yellowCtrl.text)!;
      final blue = ColorExtension.fromHex(blueCtrl.text)!;
      final purple = ColorExtension.fromHex(purpleCtrl.text)!;
      final cyan = ColorExtension.fromHex(cyanCtrl.text)!;
      final white = ColorExtension.fromHex(whiteCtrl.text)!;
      final brightBlack = ColorExtension.fromHex(brightBlackCtrl.text)!;
      final brightRed = ColorExtension.fromHex(brightRedCtrl.text)!;
      final brightGreen = ColorExtension.fromHex(brightGreenCtrl.text)!;
      final brightYellow = ColorExtension.fromHex(brightYellowCtrl.text)!;
      final brightBlue = ColorExtension.fromHex(brightBlueCtrl.text)!;
      final brightPurple = ColorExtension.fromHex(brightPurpleCtrl.text)!;
      final brightCyan = ColorExtension.fromHex(brightCyanCtrl.text)!;
      final brightWhite = ColorExtension.fromHex(brightWhiteCtrl.text)!;
      final background = ColorExtension.fromHex(backgroundCtrl.text)!;
      final foreground = ColorExtension.fromHex(foregroundCtrl.text)!;
      final cursor = ColorExtension.fromHex(cursorCtrl.text)!;
      final cursorText = ColorExtension.fromHex(cursorTextCtrl.text)!;
      final selectionBackground = ColorExtension.fromHex(
        selectionBackgroundCtrl.text,
      )!;
      final selectionForeground = ColorExtension.fromHex(
        selectionForegroundCtrl.text,
      )!;

      final CustomTerminalThemesCompanion toInsert = .insert(
        name: name,
        black: black,
        red: red,
        green: green,
        yellow: yellow,
        blue: blue,
        purple: purple,
        cyan: cyan,
        white: white,
        brightBlack: brightBlack,
        brightRed: brightRed,
        brightGreen: brightGreen,
        brightYellow: brightYellow,
        brightBlue: brightBlue,
        brightPurple: brightPurple,
        brightCyan: brightCyan,
        brightWhite: brightWhite,
        foreground: foreground,
        background: background,
        cursor: cursor,
        cursorText: cursorText,
        selectionBackground: selectionBackground,
        selectionForeground: selectionForeground,
      );

      final doesExist = await ref
          .read(terminalThemeServiceProvider)
          .doesExist(colorScheme: toInsert);

      if (doesExist) {
        await Commons.showToast(
          'terminal_themes_already_exist'.tr(),
          prefix: const Icon(LucideIcons.fileExclamationPoint),
        );
        return;
      }

      final terminalThemeService = ref.read(terminalThemeServiceProvider);
      final themeId = isEdit
          ? await terminalThemeService.update(
              current!.id.value,
              name: name,
              black: black,
              red: red,
              green: green,
              yellow: yellow,
              blue: blue,
              purple: purple,
              cyan: cyan,
              white: white,
              brightBlack: brightBlack,
              brightRed: brightRed,
              brightGreen: brightGreen,
              brightYellow: brightYellow,
              brightBlue: brightBlue,
              brightPurple: brightPurple,
              brightCyan: brightCyan,
              brightWhite: brightWhite,
              background: background,
              foreground: foreground,
              cursor: cursor,
              cursorText: cursorText,
              selectionBackground: selectionBackground,
              selectionForeground: selectionForeground,
              compareTo: current,
            )
          : await terminalThemeService.createCustomTerminalTheme(toInsert);

      if (!context.mounted) return;
      context.pop(themeId);
    }

    buildHexColorField(String labelKey, TextEditingController controller) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const gridSize = 2;
          return SizedBox(
            width:
                (constraints.maxWidth / gridSize) -
                (16 * (gridSize - 1) / gridSize),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  spacing: 8,
                  children: [
                    SizedBox.square(
                      dimension: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              ColorExtension.fromHex(controller.text) ??
                              Colors.transparent,
                          border: Border.all(
                            color: context.theme.colors.border,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FTextFormField(
                        control: .managed(
                          controller: controller,
                          onChange: (_) => setState(() {}),
                        ),
                        label: Text(
                          'terminal_themes_theme_colors.$labelKey'.tr(),
                        ),
                        hint: 'terminal_themes_theme_add_color_placeholder'
                            .tr(),
                        validator: (value) => Validators.chain(context, [
                          Validators.nonEmpty,
                          Validators.hexColor,
                        ], value),
                        inputFormatters: InputFormatters.hex(),
                        autovalidateMode: .onUserInteraction,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    return CreateOrEditEntityView(
      onSave: (_) => onSave(),
      isEdit: isEdit,
      withVaultSelector: false,
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FTextFormField(
              control: .managed(controller: nameCtrl),
              label: Text('terminal_themes_theme_add_label'.tr()),
              hint: 'terminal_themes_theme_add_label_placeholder'.tr(),
              validator: (s) => Validators.nonEmpty(context, s),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                buildHexColorField('black', blackCtrl),
                buildHexColorField('red', redCtrl),
                buildHexColorField('green', greenCtrl),
                buildHexColorField('yellow', yellowCtrl),
                buildHexColorField('blue', blueCtrl),
                buildHexColorField('purple', purpleCtrl),
                buildHexColorField('cyan', cyanCtrl),
                buildHexColorField('white', whiteCtrl),
                buildHexColorField('bright_black', brightBlackCtrl),
                buildHexColorField('bright_red', brightRedCtrl),
                buildHexColorField('bright_green', brightGreenCtrl),
                buildHexColorField('bright_yellow', brightYellowCtrl),
                buildHexColorField('bright_blue', brightBlueCtrl),
                buildHexColorField('bright_purple', brightPurpleCtrl),
                buildHexColorField('bright_cyan', brightCyanCtrl),
                buildHexColorField('bright_white', brightWhiteCtrl),
                buildHexColorField('foreground', foregroundCtrl),
                buildHexColorField('background', backgroundCtrl),
                buildHexColorField('cursor', cursorCtrl),
                buildHexColorField('cursor_text', cursorTextCtrl),
                buildHexColorField(
                  'selection_foreground',
                  selectionForegroundCtrl,
                ),
                buildHexColorField(
                  'selection_background',
                  selectionBackgroundCtrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
