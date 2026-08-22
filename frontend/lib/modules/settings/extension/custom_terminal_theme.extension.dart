import 'package:cliq_term/cliq_term.dart';

import '../../../shared/data/database.dart';

extension CustomTerminalThemeExtension on CustomTerminalTheme {
  TerminalTheme toTerminalTheme() {
    return TerminalTheme(
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
      selectionForeground: selectionForeground,
      selectionBackground: selectionBackground,
    );
  }
}
