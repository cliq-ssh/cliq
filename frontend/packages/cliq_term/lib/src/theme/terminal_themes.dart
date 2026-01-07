import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/cupertino.dart';

enum TerminalColorThemes {
  darcula(
    'Darcula',
    .new(
      cursorColor: Color(0xFFF8F8F2),
      selectionColor: Color(0xFF44475A),
      foregroundColor: Color(0xFFF8F8F2),
      backgroundColor: Color(0xFF282A36),
      black: Color(0xFF21222C),
      red: Color(0xFFFF5555),
      green: Color(0xFF50FA7B),
      yellow: Color(0xFFF1FA8C),
      blue: Color(0xFFBD93F9),
      magenta: Color(0xFFFF79C6),
      cyan: Color(0xFF8BE9FD),
      white: Color(0xFFF8F8F2),
      brightBlack: Color(0xFF6272A4),
      brightRed: Color(0xFFFF6E6E),
      brightGreen: Color(0xFF69FF94),
      brightYellow: Color(0xFFFFFFA5),
      brightBlue: Color(0xFFD6ACFF),
      brightMagenta: Color(0xFFFF92DF),
      brightCyan: Color(0xFFA4FFFF),
      brightWhite: Color(0xFFFFFFFF),
    ),
  ),
  gruvboxDark(
    'Gruvbox Dark',
    .new(
      cursorColor: Color(0xFFD4BE98),
      selectionColor: Color(0xFF3C3836),
      foregroundColor: Color(0xFFD4BE98),
      backgroundColor: Color(0xFF282828),
      black: Color(0xFF282828),
      red: Color(0xFFFB4934),
      green: Color(0xFFB8BB26),
      yellow: Color(0xFFD79921),
      blue: Color(0xFF83A598),
      magenta: Color(0xFFD3869B),
      cyan: Color(0xFF8EC07C),
      white: Color(0xFFD4BE98),
      brightBlack: Color(0xFF928374),
      brightRed: Color(0xFFFB4934),
      brightGreen: Color(0xFFB8BB26),
      brightYellow: Color(0xFFD79921),
      brightBlue: Color(0xFF83A598),
      brightMagenta: Color(0xFFD3869B),
      brightCyan: Color(0xFF8EC07C),
      brightWhite: Color(0xFFF2E5BC),
    ),
  )
  ;

  final String name;
  final TerminalColorTheme colors;
  const TerminalColorThemes(this.name, this.colors);
}
