import 'dart:ui';

import 'package:cliq/shared/data/database.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:iterm2_color_schemes_dart/iterm2_color_schemes_dart.dart';

extension ITerm2ColorSchemeExtension on ITerm2ColorScheme {
  CustomTerminalThemesCompanion toCustomTerminalThemesCompanion() {
    return CustomTerminalThemesCompanion.insert(
      name: name,
      blackColor: Color(black),
      redColor: Color(red),
      greenColor: Color(green),
      yellowColor: Color(yellow),
      blueColor: Color(blue),
      purpleColor: Color(purple),
      cyanColor: Color(cyan),
      whiteColor: Color(white),
      brightBlackColor: Color(brightBlack),
      brightRedColor: Color(brightRed),
      brightGreenColor: Color(brightGreen),
      brightYellowColor: Color(brightYellow),
      brightBlueColor: Color(brightBlue),
      brightPurpleColor: Color(brightPurple),
      brightCyanColor: Color(brightCyan),
      brightWhiteColor: Color(brightWhite),
      backgroundColor: Color(background),
      foregroundColor: Color(foreground),
      cursorColor: Color(cursorColor),
      selectionBackgroundColor: Color(selectionBackground),
    );
  }

  TerminalTheme toTerminalTheme() {
    return TerminalTheme(
      black: Color(black),
      red: Color(red),
      green: Color(green),
      yellow: Color(yellow),
      blue: Color(blue),
      purple: Color(purple),
      cyan: Color(cyan),
      white: Color(white),
      brightBlack: Color(brightBlack),
      brightRed: Color(brightRed),
      brightGreen: Color(brightGreen),
      brightYellow: Color(brightYellow),
      brightBlue: Color(brightBlue),
      brightPurple: Color(brightPurple),
      brightCyan: Color(brightCyan),
      brightWhite: Color(brightWhite),
      backgroundColor: Color(background),
      foregroundColor: Color(foreground),
      cursorColor: Color(cursorColor),
      selectionColor: Color(selectionBackground),
    );
  }
}
