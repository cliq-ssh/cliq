import 'package:flutter/services.dart';

/// Handles terminal keyboard shortcuts (Ctrl+Shift+C/V and Cmd+Shift+C/V on macOS).
class TerminalShortcuts {
  /// Check if the keyboard event is Ctrl+Shift+C (copy) or Cmd+Shift+C on macOS.
  static bool isCopyShortcut(KeyEvent event) {
    final isCtrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    return isCtrl && isShift && event.logicalKey == LogicalKeyboardKey.keyC;
  }

  /// Check if the keyboard event is Ctrl+Shift+V (paste) or Cmd+Shift+V on macOS.
  static bool isPasteShortcut(KeyEvent event) {
    final isCtrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    return isCtrl && isShift && event.logicalKey == LogicalKeyboardKey.keyV;
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
