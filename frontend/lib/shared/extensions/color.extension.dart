import 'dart:math';
import 'dart:ui';

extension ColorExtension on Color {
  String toHex({bool withAlpha = false}) {
    return '#${[if (withAlpha) a, r, g, b].map((c) => (c * 255).round().toRadixString(16).padLeft(2, '0')).join()}';
  }

  static Color generateRandom() => Color(Random().nextInt(0xffffffff));

  static Color? fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha if not provided
    }
    if (hex.length != 8) {
      return null;
    }
    final intVal = int.parse(hex, radix: 16);
    return Color(intVal);
  }
}
