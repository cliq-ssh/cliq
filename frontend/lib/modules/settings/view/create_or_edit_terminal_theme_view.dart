import 'dart:async';

import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/input_formatters.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../../../shared/extensions/color.extension.dart';
import '../../../shared/extensions/text_controller.extension.dart';
import '../provider/terminal_theme_service.provider.dart';

class CreateOrEditTerminalThemeView extends HookConsumerWidget {
  final CustomTerminalThemesCompanion? current;
  final bool isEdit;

  const CreateOrEditTerminalThemeView.create({super.key})
    : current = null,
      isEdit = false;

  CreateOrEditTerminalThemeView.edit(
    CustomTerminalTheme themeEntity, {
    super.key,
  }) : current = CustomTerminalThemesCompanion(
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
    final blackColorCtrl = useTextEditingController(
      text: current?.black.value.toHex(),
    );
    final redColorCtrl = useTextEditingController(
      text: current?.red.value.toHex(),
    );
    final greenColorCtrl = useTextEditingController(
      text: current?.green.value.toHex(),
    );
    final yellowColorCtrl = useTextEditingController(
      text: current?.yellow.value.toHex(),
    );
    final blueColorCtrl = useTextEditingController(
      text: current?.blue.value.toHex(),
    );
    final purpleColorCtrl = useTextEditingController(
      text: current?.purple.value.toHex(),
    );
    final cyanColorCtrl = useTextEditingController(
      text: current?.cyan.value.toHex(),
    );
    final whiteColorCtrl = useTextEditingController(
      text: current?.white.value.toHex(),
    );
    final brightBlackColorCtrl = useTextEditingController(
      text: current?.brightBlack.value.toHex(),
    );
    final brightRedColorCtrl = useTextEditingController(
      text: current?.brightRed.value.toHex(),
    );
    final brightGreenColorCtrl = useTextEditingController(
      text: current?.brightGreen.value.toHex(),
    );
    final brightYellowColorCtrl = useTextEditingController(
      text: current?.brightYellow.value.toHex(),
    );
    final brightBlueColorCtrl = useTextEditingController(
      text: current?.brightBlue.value.toHex(),
    );
    final brightPurpleColorCtrl = useTextEditingController(
      text: current?.brightPurple.value.toHex(),
    );
    final brightCyanColorCtrl = useTextEditingController(
      text: current?.brightCyan.value.toHex(),
    );
    final brightWhiteColorCtrl = useTextEditingController(
      text: current?.brightWhite.value.toHex(),
    );
    final foregroundColorCtrl = useTextEditingController(
      text: current?.foreground.value.toHex(),
    );
    final backgroundColorCtrl = useTextEditingController(
      text: current?.background.value.toHex(),
    );
    final cursorColorCtrl = useTextEditingController(
      text: current?.cursor.value.toHex(),
    );
    final cursorTextColorCtrl = useTextEditingController(
      text: current?.cursorText.value.toHex(),
    );
    final selectionBackgroundColorCtrl = useTextEditingController(
      text: current?.selectionBackground.value.toHex(),
    );
    final selectionForegroundColorCtrl = useTextEditingController(
      text: current?.selectionForeground.value.toHex(),
    );

    /// Handles the save action for the form.
    Future<void> onSave() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final Color? blackColor = ColorExtension.fromHex(blackColorCtrl.text);
      final Color? redColor = ColorExtension.fromHex(redColorCtrl.text);
      final Color? greenColor = ColorExtension.fromHex(greenColorCtrl.text);
      final Color? yellowColor = ColorExtension.fromHex(yellowColorCtrl.text);
      final Color? blueColor = ColorExtension.fromHex(blueColorCtrl.text);
      final Color? purpleColor = ColorExtension.fromHex(purpleColorCtrl.text);
      final Color? cyanColor = ColorExtension.fromHex(cyanColorCtrl.text);
      final Color? whiteColor = ColorExtension.fromHex(whiteColorCtrl.text);
      final Color? brightBlackColor = ColorExtension.fromHex(
        brightBlackColorCtrl.text,
      );
      final Color? brightRedColor = ColorExtension.fromHex(
        brightRedColorCtrl.text,
      );
      final Color? brightGreenColor = ColorExtension.fromHex(
        brightGreenColorCtrl.text,
      );
      final Color? brightYellowColor = ColorExtension.fromHex(
        brightYellowColorCtrl.text,
      );
      final Color? brightBlueColor = ColorExtension.fromHex(
        brightBlueColorCtrl.text,
      );
      final Color? brightPurpleColor = ColorExtension.fromHex(
        brightPurpleColorCtrl.text,
      );
      final Color? brightCyanColor = ColorExtension.fromHex(
        brightCyanColorCtrl.text,
      );
      final Color? brightWhiteColor = ColorExtension.fromHex(
        brightWhiteColorCtrl.text,
      );
      final Color? foregroundColor = ColorExtension.fromHex(
        foregroundColorCtrl.text,
      );
      final Color? backgroundColor = ColorExtension.fromHex(
        backgroundColorCtrl.text,
      );
      final Color? cursorColor = ColorExtension.fromHex(cursorColorCtrl.text);
      final Color? selectionBackgroundColor = ColorExtension.fromHex(
        selectionBackgroundColorCtrl.text,
      );
      final Color? selectionForegroundColor = ColorExtension.fromHex(
        selectionForegroundColorCtrl.text,
      );
      final Color? cursorTextColor = ColorExtension.fromHex(
        cursorTextColorCtrl.text,
      );

      final terminalThemeService = ref.read(terminalThemeServiceProvider);
      final themeId = isEdit
          ? await terminalThemeService.update(
              current!.id.value,
              name: nameCtrl.textOrNull,
              black: blackColor,
              red: redColor,
              green: greenColor,
              yellow: yellowColor,
              blue: blueColor,
              purple: purpleColor,
              cyan: cyanColor,
              white: whiteColor,
              brightBlack: brightBlackColor,
              brightRed: brightRedColor,
              brightGreen: brightGreenColor,
              brightYellow: brightYellowColor,
              brightBlue: brightBlueColor,
              brightPurple: brightPurpleColor,
              brightCyan: brightCyanColor,
              brightWhite: brightWhiteColor,
              background: backgroundColor,
              foreground: foregroundColor,
              cursor: cursorColor,
              selectionBackground: selectionBackgroundColor,
              selectionForeground: selectionForegroundColor,
              cursorText: cursorTextColor,
              compareTo: current,
            )
          : await terminalThemeService.createCustomTerminalTheme(
              CustomTerminalThemesCompanion.insert(
                name: nameCtrl.text.trim(),
                black: blackColor!,
                red: redColor!,
                green: greenColor!,
                yellow: yellowColor!,
                blue: blueColor!,
                purple: purpleColor!,
                cyan: cyanColor!,
                white: whiteColor!,
                brightBlack: brightBlackColor!,
                brightRed: brightRedColor!,
                brightGreen: brightGreenColor!,
                brightYellow: brightYellowColor!,
                brightBlue: brightBlueColor!,
                brightPurple: brightPurpleColor!,
                brightCyan: brightCyanColor!,
                brightWhite: brightWhiteColor!,
                foreground: foregroundColor!,
                background: backgroundColor!,
                cursor: cursorColor!,
                cursorText: cursorTextColor!,
                selectionBackground: selectionBackgroundColor!,
                selectionForeground: selectionForegroundColor!,
              ),
            );

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
                buildHexColorField('black', blackColorCtrl),
                buildHexColorField('red', redColorCtrl),
                buildHexColorField('green', greenColorCtrl),
                buildHexColorField('yellow', yellowColorCtrl),
                buildHexColorField('blue', blueColorCtrl),
                buildHexColorField('purple', purpleColorCtrl),
                buildHexColorField('cyan', cyanColorCtrl),
                buildHexColorField('white', whiteColorCtrl),
                buildHexColorField('bright_black', brightBlackColorCtrl),
                buildHexColorField('bright_red', brightRedColorCtrl),
                buildHexColorField('bright_green', brightGreenColorCtrl),
                buildHexColorField('bright_yellow', brightYellowColorCtrl),
                buildHexColorField('bright_blue', brightBlueColorCtrl),
                buildHexColorField('bright_purple', brightPurpleColorCtrl),
                buildHexColorField('bright_cyan', brightCyanColorCtrl),
                buildHexColorField('bright_white', brightWhiteColorCtrl),
                buildHexColorField('foreground', foregroundColorCtrl),
                buildHexColorField('background', backgroundColorCtrl),
                buildHexColorField('cursor', cursorColorCtrl),
                buildHexColorField('cursor_text', cursorTextColorCtrl),
                buildHexColorField(
                  'selection_foreground',
                  selectionForegroundColorCtrl,
                ),
                buildHexColorField(
                  'selection_background',
                  selectionBackgroundColorCtrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
