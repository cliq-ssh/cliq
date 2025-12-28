import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/cupertino.dart';

Color rgbToColor(int r, int g, int b) =>
    Color.fromARGB(0xFF, r & 0xFF, g & 0xFF, b & 0xFF);

Color ansi8ToColor(TerminalColorTheme colors, int code) {
  final base = [
    colors.black,
    colors.red,
    colors.green,
    colors.yellow,
    colors.blue,
    colors.magenta,
    colors.cyan,
    colors.white,
  ];
  return base[code.clamp(0, base.length - 1)];
}

Color ansi16ToColor(TerminalColorTheme colors, int index) {
  final palette = [
    colors.black,
    colors.red,
    colors.green,
    colors.yellow,
    colors.blue,
    colors.magenta,
    colors.cyan,
    colors.white,
    colors.brightBlack,
    colors.brightRed,
    colors.brightGreen,
    colors.brightYellow,
    colors.brightBlue,
    colors.brightMagenta,
    colors.brightCyan,
    colors.brightWhite,
  ];
  return palette[index.clamp(0, palette.length - 1)];
}

Color xterm256ToColor(TerminalColorTheme colors, int index) {
  index = index & 0xFF;
  if (index < 16) return ansi16ToColor(colors, index);
  if (index >= 232) {
    final gray = ((index - 232) * 10) + 8;
    return Color.fromARGB(0xFF, gray, gray, gray);
  }
  final i = index - 16;
  final r = (i ~/ 36) % 6;
  final g = (i ~/ 6) % 6;
  final b = i % 6;
  int map6(int v) => v == 0 ? 0 : 55 + v * 40; // common xterm calc
  return Color.fromARGB(0xFF, map6(r), map6(g), map6(b));
}
