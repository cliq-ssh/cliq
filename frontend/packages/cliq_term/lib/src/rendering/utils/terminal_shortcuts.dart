import 'package:flutter/services.dart';

/// Handles terminal keyboard shortcuts (Ctrl+Shift+C/V and Cmd+Shift+C/V on macOS).
class TerminalShortcuts {
  const TerminalShortcuts._();

  static final Map<LogicalKeyboardKey, String> _controlCharacterMap = {
    LogicalKeyboardKey.keyA: '\x01',
    LogicalKeyboardKey.keyB: '\x02',
    LogicalKeyboardKey.keyC: '\x03',
    LogicalKeyboardKey.keyD: '\x04',
    LogicalKeyboardKey.keyE: '\x05',
    LogicalKeyboardKey.keyF: '\x06',
    LogicalKeyboardKey.keyG: '\x07',
    LogicalKeyboardKey.keyH: '\x08',
    LogicalKeyboardKey.keyI: '\x09',
    LogicalKeyboardKey.keyJ: '\x0A',
    LogicalKeyboardKey.keyK: '\x0B',
    LogicalKeyboardKey.keyL: '\x0C',
    LogicalKeyboardKey.keyM: '\x0D',
    LogicalKeyboardKey.keyN: '\x0E',
    LogicalKeyboardKey.keyO: '\x0F',
    LogicalKeyboardKey.keyP: '\x10',
    LogicalKeyboardKey.keyQ: '\x11',
    LogicalKeyboardKey.keyR: '\x12',
    LogicalKeyboardKey.keyS: '\x13',
    LogicalKeyboardKey.keyT: '\x14',
    LogicalKeyboardKey.keyU: '\x15',
    LogicalKeyboardKey.keyV: '\x16',
    LogicalKeyboardKey.keyW: '\x17',
    LogicalKeyboardKey.keyX: '\x18',
    LogicalKeyboardKey.keyY: '\x19',
    LogicalKeyboardKey.keyZ: '\x1A',
  };

  /// Returns the ASCII control character for a letter key, if it exists.
  static String? controlCharacterForKey(LogicalKeyboardKey key) {
    return _controlCharacterMap[key];
  }

  /// Strip trailing newlines from multiline text to prevent auto-execution.
  /// Returns trimmed text if multiline, otherwise returns original text.
  ///
  /// TODO: There is a escape code that prevents auto-execution of pasted commands, but it is not implemented atm.
  static String stripTrailingNewlines(String text) {
    if (text.contains('\n') && text.endsWith('\n')) {
      return text.trimRight();
    }
    return text;
  }
}
