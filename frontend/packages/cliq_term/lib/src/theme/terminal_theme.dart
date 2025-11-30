import 'dart:ui';

import 'package:cliq_term/src/theme/typography.dart';

class TerminalColorTheme {
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
  final Color magenta;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightMagenta;
  final Color brightCyan;
  final Color brightWhite;

  const TerminalColorTheme({
    required this.cursorColor,
    required this.selectionColor,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightMagenta,
    required this.brightCyan,
    required this.brightWhite,
  });
}
