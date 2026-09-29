import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

extension LevelExtension on Level {
  static final _levelToColor = {
    Level.SHOUT.value: Colors.purple,
    Level.SEVERE.value: Colors.red,
    Level.WARNING.value: Colors.orange,
    Level.INFO.value: Colors.green,
    Level.CONFIG.value: Colors.cyan,
    Level.FINE.value: Colors.grey,
    Level.FINER.value: Colors.grey.shade600,
    Level.FINEST.value: Colors.grey.shade400,
  };

  static Level fromValue(int value) {
    final level = Level.LEVELS.where((l) => l.value == value).firstOrNull;
    if (level == null) {
      throw ArgumentError('No Level found for value: $value');
    }
    return level;
  }

  Color toColor() => _levelToColor[value] ?? Colors.grey;
}
