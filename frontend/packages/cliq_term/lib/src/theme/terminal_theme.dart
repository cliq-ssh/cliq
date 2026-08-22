import 'dart:ui';

class TerminalTheme {
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color purple;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightPurple;
  final Color brightCyan;
  final Color brightWhite;

  final Color cursor;
  final Color cursorText;
  final Color background;
  final Color foreground;
  final Color selectionForeground;
  final Color selectionBackground;

  const TerminalTheme({
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.purple,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightPurple,
    required this.brightCyan,
    required this.brightWhite,
    required this.cursor,
    required this.cursorText,
    required this.background,
    required this.foreground,
    required this.selectionForeground,
    required this.selectionBackground,
  });
}
