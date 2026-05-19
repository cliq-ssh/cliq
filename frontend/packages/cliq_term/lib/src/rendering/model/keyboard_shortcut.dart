import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeyboardShortcut {
  final LogicalKeyboardKey logicalKey;
  final Set<LogicalKeyboardKey> modifiers;

  KeyboardShortcut(this.logicalKey, {this.modifiers = const {}})
    : assert(
        modifiers.every(
          (mod) =>
              mod == .shift || mod == .control || mod == .alt || mod == .meta,
        ),
        'Modifiers can only be shift, control, alt, or meta',
      );

  /// Checks if the given [KeyEvent] matches this shortcut.
  bool isPressed(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != logicalKey) return false;

    if (modifiers.contains(LogicalKeyboardKey.shift) !=
        HardwareKeyboard.instance.isShiftPressed) {
      return false;
    }
    if (modifiers.contains(LogicalKeyboardKey.control) !=
        HardwareKeyboard.instance.isControlPressed) {
      return false;
    }
    if (modifiers.contains(LogicalKeyboardKey.alt) !=
        HardwareKeyboard.instance.isAltPressed) {
      return false;
    }
    if (modifiers.contains(LogicalKeyboardKey.meta) !=
        HardwareKeyboard.instance.isMetaPressed) {
      return false;
    }

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is KeyboardShortcut &&
        other.logicalKey == logicalKey &&
        setEquals(other.modifiers, modifiers);
  }

  @override
  int get hashCode => logicalKey.hashCode ^ modifiers.hashCode;
}
