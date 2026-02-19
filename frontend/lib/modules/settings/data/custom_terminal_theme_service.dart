import 'dart:ui';

import 'package:cliq/modules/settings/data/custom_terminal_themes_repository.dart';
import 'package:cliq/shared/data/database.dart';

import '../../../shared/extensions/value.extension.dart';

final class CustomTerminalThemeService {
  final CustomTerminalThemesRepository _customTerminalThemesRepository;

  const CustomTerminalThemeService(this._customTerminalThemesRepository);

  Stream<List<CustomTerminalTheme>> watchAll() {
    return _customTerminalThemesRepository.selectAll().watch();
  }

  Future<int> createCustomTerminalTheme(
    CustomTerminalThemesCompanion insert,
  ) async {
    return await _customTerminalThemesRepository.insert(insert);
  }

  Future<int> update(
    int themeId, {
    required String? name,
    required Color? black,
    required Color? red,
    required Color? green,
    required Color? yellow,
    required Color? blue,
    required Color? purple,
    required Color? cyan,
    required Color? white,
    required Color? brightBlack,
    required Color? brightRed,
    required Color? brightGreen,
    required Color? brightYellow,
    required Color? brightBlue,
    required Color? brightPurple,
    required Color? brightCyan,
    required Color? brightWhite,
    required Color? background,
    required Color? foreground,
    required Color? cursorColor,
    required Color? selectionBackground,
    required Color? selectionForeground,
    required Color? cursorTextColor,
    CustomTerminalThemesCompanion? compareTo,
  }) async {
    await _customTerminalThemesRepository.updateById(
      themeId,
      CustomTerminalThemesCompanion(
        name: ValueExtension.absentIfNullOrSame(name, compareTo?.name),
        blackColor: ValueExtension.absentIfNullOrSame(
          black,
          compareTo?.blackColor,
        ),
        redColor: ValueExtension.absentIfNullOrSame(red, compareTo?.redColor),
        greenColor: ValueExtension.absentIfNullOrSame(
          green,
          compareTo?.greenColor,
        ),
        yellowColor: ValueExtension.absentIfNullOrSame(
          yellow,
          compareTo?.yellowColor,
        ),
        blueColor: ValueExtension.absentIfNullOrSame(
          blue,
          compareTo?.blueColor,
        ),
        purpleColor: ValueExtension.absentIfNullOrSame(
          purple,
          compareTo?.purpleColor,
        ),
        cyanColor: ValueExtension.absentIfNullOrSame(
          cyan,
          compareTo?.cyanColor,
        ),
        whiteColor: ValueExtension.absentIfNullOrSame(
          white,
          compareTo?.whiteColor,
        ),
        brightBlackColor: ValueExtension.absentIfNullOrSame(
          brightBlack,
          compareTo?.brightBlackColor,
        ),
        brightRedColor: ValueExtension.absentIfNullOrSame(
          brightRed,
          compareTo?.brightRedColor,
        ),
        brightGreenColor: ValueExtension.absentIfNullOrSame(
          brightGreen,
          compareTo?.brightGreenColor,
        ),
        brightYellowColor: ValueExtension.absentIfNullOrSame(
          brightYellow,
          compareTo?.brightYellowColor,
        ),
        brightBlueColor: ValueExtension.absentIfNullOrSame(
          brightBlue,
          compareTo?.brightBlueColor,
        ),
        brightPurpleColor: ValueExtension.absentIfNullOrSame(
          brightPurple,
          compareTo?.brightPurpleColor,
        ),
        brightCyanColor: ValueExtension.absentIfNullOrSame(
          brightCyan,
          compareTo?.brightCyanColor,
        ),
        brightWhiteColor: ValueExtension.absentIfNullOrSame(
          brightWhite,
          compareTo?.brightWhiteColor,
        ),
        backgroundColor: ValueExtension.absentIfNullOrSame(
          background,
          compareTo?.backgroundColor,
        ),
        foregroundColor: ValueExtension.absentIfNullOrSame(
          foreground,
          compareTo?.foregroundColor,
        ),
        cursorColor: ValueExtension.absentIfNullOrSame(
          cursorColor,
          compareTo?.cursorColor,
        ),
        selectionBackgroundColor: ValueExtension.absentIfNullOrSame(
          selectionBackground!,
          compareTo?.selectionBackgroundColor,
        ),
        selectionForegroundColor: ValueExtension.absentIfSame(
          selectionForeground,
          compareTo?.selectionForegroundColor.value,
        ),
        cursorTextColor: ValueExtension.absentIfSame(
          cursorTextColor,
          compareTo?.cursorTextColor.value,
        ),
      ),
    );
    return themeId;
  }

  Future<void> deleteById(int id) =>
      _customTerminalThemesRepository.deleteById(id);
}
