import 'package:flutter/foundation.dart';

/// Actions an accessory-bar item can invoke, injected by [TerminalView].
class TerminalAccessoryBarActions {
  /// Sends [text] as terminal input, applying any active one-shot
  /// modifiers (Ctrl/Alt) first, then clearing them.
  final void Function(String text) sendInput;

  final ValueListenable<bool> keyboardVisible;

  final VoidCallback openKeyboard;
  final VoidCallback closeKeyboard;

  /// Whether Ctrl is armed for the next [sendInput] call.
  final ValueListenable<bool> ctrlActive;
  final VoidCallback toggleCtrl;

  /// Whether Alt is armed for the next [sendInput] call.
  final ValueListenable<bool> altActive;
  final VoidCallback toggleAlt;

  const TerminalAccessoryBarActions({
    required this.sendInput,
    required this.keyboardVisible,
    required this.openKeyboard,
    required this.closeKeyboard,
    required this.ctrlActive,
    required this.toggleCtrl,
    required this.altActive,
    required this.toggleAlt,
  });

  void toggleKeyboard() =>
      keyboardVisible.value ? closeKeyboard() : openKeyboard();
}
