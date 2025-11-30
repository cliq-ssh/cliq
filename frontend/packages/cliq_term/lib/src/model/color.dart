import 'package:flutter/cupertino.dart';

Color rgbToColor(int r, int g, int b) =>
    Color.fromARGB(0xFF, r & 0xFF, g & 0xFF, b & 0xFF);

Color ansi8ToColor(int code) {
  const base = [
    0xFF000000,
    0xFFAA0000,
    0xFF00AA00,
    0xFFAA5500,
    0xFF0000AA,
    0xFFAA00AA,
    0xFF00AAAA,
    0xFFAAAAAA,
  ];
  final c = base[code.clamp(0, base.length - 1)];
  return Color(c);
}

Color xterm256ToColor(int index) {
  index = index & 0xFF;
  if (index < 16) return ansi16ToColor(index);
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

Color ansi16ToColor(int index) {
  const palette = [
    0xFF000000,
    0xFF800000,
    0xFF008000,
    0xFF808000,
    0xFF000080,
    0xFF800080,
    0xFF008080,
    0xFFC0C0C0,
    0xFF808080,
    0xFFFF0000,
    0xFF00FF00,
    0xFFFFFF00,
    0xFF0000FF,
    0xFFFF00FF,
    0xFF00FFFF,
    0xFFFFFFFF,
  ];
  return Color(palette[index.clamp(0, palette.length - 1)]);
}
