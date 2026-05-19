import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/services.dart';

extension KeyboardShortcutExtension on KeyboardShortcut {
  static KeyboardShortcut? tryFromJson(Map<String, dynamic> json) {
    if (!json.containsKey('k') || !json.containsKey('m')) {
      return null;
    }

    return KeyboardShortcut(
      LogicalKeyboardKey(json['k']),
      modifiers: (json['m'] as List).map((m) => LogicalKeyboardKey(m)).toSet(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'k': logicalKey.keyId, 'm': modifiers.map((m) => m.keyId).toList()};
  }
}
