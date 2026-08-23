import 'package:cliq/shared/data/database.dart';
import 'package:cliq_term/cliq_term.dart';

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
