import 'dart:ui';

extension ColorExtension on Color {
  String toHex() {
    return '#${[a, r, g, b].map((c) => (c * 255).round().toRadixString(16).padLeft(2, '0')).join()}';
  }

  static Color? fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha if not provided
    }
    if (hex.length != 8) {
      throw ArgumentError('Hex color must be 6 or 8 characters long');
    }
    final intVal = int.parse(hex, radix: 16);
    return Color(intVal);
  }
}
