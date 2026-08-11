import 'dart:ui';

import 'package:cliq/shared/data/database.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:iterm2_color_schemes_dart/iterm2_color_schemes_dart.dart';

extension ITerm2ColorSchemeExtension on ITerm2ColorScheme {
  CustomTerminalThemesCompanion toCustomTerminalThemesCompanion() {
    return CustomTerminalThemesCompanion.insert(
      name: name,
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
      background: Color(background),
      foreground: Color(foreground),
      cursor: Color(cursor),
      cursorText: Color(cursorText),
      selectionForeground: Color(selectionForeground),
      selectionBackground: Color(selectionBackground),
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
      background: Color(background),
      foreground: Color(foreground),
      cursor: Color(cursor),
      cursorText: Color(cursorText),
      selectionForeground: Color(selectionForeground),
      selectionBackground: Color(selectionBackground),
    );
  }
}
