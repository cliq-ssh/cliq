import 'dart:io';

import 'package:cliq/modules/settings/extension/keyboard_shortcut.extension.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// A default set of keyboard shortcuts for various systems.
final defaultShortcuts = KeyboardShortcuts({
  .copy: KeyboardShortcut(
    LogicalKeyboardKey.keyC,
    modifiers: {.control, .shift},
  ),
  .paste: KeyboardShortcut(
    LogicalKeyboardKey.keyV,
    modifiers: {.control, .shift},
  ),
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

  String getDisplayName() {
    return switch (this) {
      .copy => 'shortcut.copy'.tr(),
      .paste => 'shortcut.paste'.tr(),
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

      final type = KeyboardShortcutType.values.firstWhere(
        (t) => t.name == entry.key,
      );
      final shortcut = KeyboardShortcutExtension.tryFromJson(entry.value);
      if (shortcut != null) {
        shortcuts[type] = shortcut;
      }
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
