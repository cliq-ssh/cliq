import 'dart:async';

import 'package:cliq/shared/utils/input_formatters.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';
import '../../../shared/extensions/color.extension.dart';
import '../../../shared/extensions/text_controller.extension.dart';

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
         blackColor: Value(themeEntity.blackColor),
         redColor: Value(themeEntity.redColor),
         greenColor: Value(themeEntity.greenColor),
         yellowColor: Value(themeEntity.yellowColor),
         blueColor: Value(themeEntity.blueColor),
         purpleColor: Value(themeEntity.purpleColor),
         cyanColor: Value(themeEntity.cyanColor),
         whiteColor: Value(themeEntity.whiteColor),
         brightBlackColor: Value(themeEntity.brightBlackColor),
         brightRedColor: Value(themeEntity.brightRedColor),
         brightGreenColor: Value(themeEntity.brightGreenColor),
         brightYellowColor: Value(themeEntity.brightYellowColor),
         brightBlueColor: Value(themeEntity.brightBlueColor),
         brightPurpleColor: Value(themeEntity.brightPurpleColor),
         brightCyanColor: Value(themeEntity.brightCyanColor),
         brightWhiteColor: Value(themeEntity.brightWhiteColor),
         foregroundColor: Value(themeEntity.foregroundColor),
         backgroundColor: Value(themeEntity.backgroundColor),
         cursorColor: Value(themeEntity.cursorColor),
         selectionBackgroundColor: Value(themeEntity.selectionBackgroundColor),
         selectionForegroundColor: Value(themeEntity.selectionForegroundColor),
         cursorTextColor: Value(themeEntity.cursorTextColor),
       ),
       isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameCtrl = useTextEditingController(text: current?.name.value);
    final blackColorCtrl = useTextEditingController(
      text: current?.blackColor.value.toHex(),
    );
    final redColorCtrl = useTextEditingController(
      text: current?.redColor.value.toHex(),
    );
    final greenColorCtrl = useTextEditingController(
      text: current?.greenColor.value.toHex(),
    );
    final yellowColorCtrl = useTextEditingController(
      text: current?.yellowColor.value.toHex(),
    );
    final blueColorCtrl = useTextEditingController(
      text: current?.blueColor.value.toHex(),
    );
    final purpleColorCtrl = useTextEditingController(
      text: current?.purpleColor.value.toHex(),
    );
    final cyanColorCtrl = useTextEditingController(
      text: current?.cyanColor.value.toHex(),
    );
    final whiteColorCtrl = useTextEditingController(
      text: current?.whiteColor.value.toHex(),
    );
    final brightBlackColorCtrl = useTextEditingController(
      text: current?.brightBlackColor.value.toHex(),
    );
    final brightRedColorCtrl = useTextEditingController(
      text: current?.brightRedColor.value.toHex(),
    );
    final brightGreenColorCtrl = useTextEditingController(
      text: current?.brightGreenColor.value.toHex(),
    );
    final brightYellowColorCtrl = useTextEditingController(
      text: current?.brightYellowColor.value.toHex(),
    );
    final brightBlueColorCtrl = useTextEditingController(
      text: current?.brightBlueColor.value.toHex(),
    );
    final brightPurpleColorCtrl = useTextEditingController(
      text: current?.brightPurpleColor.value.toHex(),
    );
    final brightCyanColorCtrl = useTextEditingController(
      text: current?.brightCyanColor.value.toHex(),
    );
    final brightWhiteColorCtrl = useTextEditingController(
      text: current?.brightWhiteColor.value.toHex(),
    );
    final foregroundColorCtrl = useTextEditingController(
      text: current?.foregroundColor.value.toHex(),
    );
    final backgroundColorCtrl = useTextEditingController(
      text: current?.backgroundColor.value.toHex(),
    );
    final cursorColorCtrl = useTextEditingController(
      text: current?.cursorColor.value.toHex(),
    );
    final selectionBackgroundColorCtrl = useTextEditingController(
      text: current?.selectionBackgroundColor.value.toHex(),
    );
    final selectionForegroundColorCtrl = useTextEditingController(
      text: current?.selectionForegroundColor.value?.toHex(),
    );
    final cursorTextColorCtrl = useTextEditingController(
      text: current?.cursorTextColor.value?.toHex(),
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

      final themeId = isEdit
          ? await CliqDatabase.customTerminalThemeService.update(
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
              cursorColor: cursorColor,
              selectionBackground: selectionBackgroundColor,
              selectionForeground: selectionForegroundColor,
              cursorTextColor: cursorTextColor,
              compareTo: current,
            )
          : await CliqDatabase.customTerminalThemeService
                .createCustomTerminalTheme(
                  CustomTerminalThemesCompanion.insert(
                    name: nameCtrl.text.trim(),
                    blackColor: blackColor!,
                    redColor: redColor!,
                    greenColor: greenColor!,
                    yellowColor: yellowColor!,
                    blueColor: blueColor!,
                    purpleColor: purpleColor!,
                    cyanColor: cyanColor!,
                    whiteColor: whiteColor!,
                    brightBlackColor: brightBlackColor!,
                    brightRedColor: brightRedColor!,
                    brightGreenColor: brightGreenColor!,
                    brightYellowColor: brightYellowColor!,
                    brightBlueColor: brightBlueColor!,
                    brightPurpleColor: brightPurpleColor!,
                    brightCyanColor: brightCyanColor!,
                    brightWhiteColor: brightWhiteColor!,
                    foregroundColor: foregroundColor!,
                    backgroundColor: backgroundColor!,
                    cursorColor: cursorColor!,
                    selectionBackgroundColor: selectionBackgroundColor!,
                    selectionForegroundColor: Value(selectionForegroundColor),
                    cursorTextColor: Value(cursorTextColor),
                  ),
                );

      if (!context.mounted) return;
      context.pop(themeId);
    }

    buildHexColorField(
      String label,
      TextEditingController controller, {
      bool required = true,
    }) {
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
                        label: Text(label),
                        hint: '#RRGGBB',
                        validator: (value) => Validators.chain([
                          if (required) Validators.nonEmpty,
                          Validators.hexColor,
                        ], value),
                        inputFormatters: required
                            ? InputFormatters.hex()
                            : null,
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

    return FScaffold(
      child: SingleChildScrollView(
        padding: const .symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton.icon(
                  variant: .outline,
                  onPress: () => context.pop(),
                  child: const Icon(LucideIcons.x),
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
                    control: .managed(controller: nameCtrl),
                    label: const Text('Name'),
                    hint: 'My Theme',
                    validator: Validators.nonEmpty,
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      buildHexColorField('Black', blackColorCtrl),
                      buildHexColorField('Red', redColorCtrl),
                      buildHexColorField('Green', greenColorCtrl),
                      buildHexColorField('Yellow', yellowColorCtrl),
                      buildHexColorField('Blue', blueColorCtrl),
                      buildHexColorField('Purple', purpleColorCtrl),
                      buildHexColorField('Cyan', cyanColorCtrl),
                      buildHexColorField('White', whiteColorCtrl),
                      buildHexColorField('Bright Black', brightBlackColorCtrl),
                      buildHexColorField('Bright Red', brightRedColorCtrl),
                      buildHexColorField('Bright Green', brightGreenColorCtrl),
                      buildHexColorField(
                        'Bright Yellow',
                        brightYellowColorCtrl,
                      ),
                      buildHexColorField('Bright Blue', brightBlueColorCtrl),
                      buildHexColorField(
                        'Bright Purple',
                        brightPurpleColorCtrl,
                      ),
                      buildHexColorField('Bright Cyan', brightCyanColorCtrl),
                      buildHexColorField('Bright White', brightWhiteColorCtrl),
                      buildHexColorField('Foreground', foregroundColorCtrl),
                      buildHexColorField('Background', backgroundColorCtrl),
                      buildHexColorField('Cursor', cursorColorCtrl),
                      buildHexColorField(
                        'Selection Background',
                        selectionBackgroundColorCtrl,
                      ),
                    ],
                  ),
                  const FDivider(),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      buildHexColorField(
                        'Selection Foreground',
                        selectionForegroundColorCtrl,
                        required: false,
                      ),
                      buildHexColorField(
                        'Cursor Text Color',
                        cursorTextColorCtrl,
                        required: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

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
