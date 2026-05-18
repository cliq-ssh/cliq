import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// A default set of keyboard shortcuts for various systems.
final defaultShortcuts = KeyboardShortcuts({
  .copy: KeyboardShortcut(LogicalKeyboardKey.keyC, modifiers: {.control}),
  .paste: KeyboardShortcut(LogicalKeyboardKey.keyV, modifiers: {.control}),
});

/// A default set of keyboard shortcuts for macOS.
final defaultMacShortcuts = KeyboardShortcuts({
  .copy: KeyboardShortcut(LogicalKeyboardKey.keyC, modifiers: {.meta}),
  .paste: KeyboardShortcut(LogicalKeyboardKey.keyV, modifiers: {.meta}),
});

enum KeyboardShortcutType {
  copy,
  paste;

  const KeyboardShortcutType();

  String getDisplayName(BuildContext context) {
    return switch (this) {
      .copy => 'Copy',
      .paste => 'Paste',
    };
  }
}

/// A class representing a collection of keyboard shortcuts for various actions.
class KeyboardShortcuts {
  final Map<KeyboardShortcutType, KeyboardShortcut> shortcuts;

  const KeyboardShortcuts(this.shortcuts);

  factory KeyboardShortcuts.fromJson(Map<String, dynamic> json) {
    final shortcuts = <KeyboardShortcutType, KeyboardShortcut>{};
    // loop through all entries
    for (final entry in json.entries) {
      // check if key even exists
      if (!KeyboardShortcutType.values.any((e) => e.name == entry.key)) {
        continue;
      }

      final shortcutKey = KeyboardShortcutType.values.firstWhere(
        (e) => e.name == entry.key,
      );
      shortcuts[shortcutKey] = KeyboardShortcut.fromJson(entry.value);
    }
    return KeyboardShortcuts(shortcuts);
  }

  static KeyboardShortcuts merge(
    KeyboardShortcuts base,
    KeyboardShortcuts overrides,
  ) {
    return KeyboardShortcuts({
      for (final shortcut in KeyboardShortcutType.values)
        shortcut: overrides.shortcuts[shortcut] ?? base.shortcuts[shortcut]!,
    });
  }

  static KeyboardShortcuts get platformDefaults {
    if (Platform.isMacOS) {
      return defaultMacShortcuts;
    }
    return defaultShortcuts;
  }

  KeyboardShortcuts copyWith({
    Map<KeyboardShortcutType, KeyboardShortcut>? shortcuts,
  }) {
    return KeyboardShortcuts(shortcuts ?? this.shortcuts);
  }

  Map<String, dynamic> toJson() {
    return {
      for (final entry in shortcuts.entries)
        entry.key.name: entry.value.toJson(),
    };
  }
}

class KeyboardShortcut {
  final LogicalKeyboardKey mainKey;
  final Set<LogicalKeyboardKey> modifiers;

  KeyboardShortcut(this.mainKey, {this.modifiers = const {}})
    : assert(
        modifiers.every(
          (mod) =>
              mod == .shift || mod == .control || mod == .alt || mod == .meta,
        ),
        'Modifiers can only be shift, control, alt, or meta',
      );

  factory KeyboardShortcut.fromJson(Map<String, dynamic> json) {
    final mainKeyId = json['k'] as int;
    final modifierIds = (json['m'] as List<dynamic>).cast<int>();

    return KeyboardShortcut(
      LogicalKeyboardKey(mainKeyId),
      modifiers: modifierIds.map((id) => LogicalKeyboardKey(id)).toSet(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'k': mainKey.keyId, 'm': modifiers.map((m) => m.keyId).toList()};
  }
}
