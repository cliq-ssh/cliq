import 'package:flutter/cupertino.dart';

enum ConnectionColor {
  red(Color(0xFFEF4444)),
  orange(Color(0xFFF97316)),
  yellow(Color(0xFFEAB308)),
  green(Color(0xFF22C55E)),
  blue(Color(0xFF3B82F6)),
  purple(Color(0xFF8B5CF6)),
  pink(Color(0xFFEC4899));

  final Color color;
  const ConnectionColor(this.color);
}
