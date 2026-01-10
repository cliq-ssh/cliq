import 'dart:ui';

class TerminalTheme {
  final Color cursorColor;
  final Color selectionColor;
  final Color foregroundColor;
  final Color backgroundColor;

  // ansi colors
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

  const TerminalTheme({
    required this.cursorColor,
    required this.selectionColor,
    required this.foregroundColor,
    required this.backgroundColor,
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
  });
}
