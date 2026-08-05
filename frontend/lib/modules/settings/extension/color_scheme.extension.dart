import 'dart:ui';

import 'package:cliq_term/cliq_term.dart';
import 'package:iterm2_color_schemes_dart/iterm2_color_schemes_dart.dart';

extension ITerm2ColorSchemeExtension on ITerm2ColorScheme {
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
