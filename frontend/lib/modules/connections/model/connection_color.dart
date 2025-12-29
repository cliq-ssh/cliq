import 'package:flutter/cupertino.dart';

enum ConnectionColor {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
  pink,
  gray;

  const ConnectionColor();

  Color getColor() {
    return switch (this) {
      ConnectionColor.red => const Color(0xFFEF4444),
      ConnectionColor.orange => const Color(0xFFF97316),
      ConnectionColor.yellow => const Color(0xFFEAB308),
      ConnectionColor.green => const Color(0xFF22C55E),
      ConnectionColor.blue => const Color(0xFF3B82F6),
      ConnectionColor.purple => const Color(0xFF8B5CF6),
      ConnectionColor.pink => const Color(0xFFEC4899),
      ConnectionColor.gray => const Color(0xFF6B7280),
    };
  }
}
