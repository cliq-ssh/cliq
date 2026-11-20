import 'dart:io';

import 'package:cliq/modules/settings/model/keyboard_shortcut.model.dart';
import 'package:easy_localization/easy_localization.dart';

/// A default set of keyboard shortcuts for various systems.
final defaultShortcuts = KeyboardShortcuts({
  .home: KeyboardShortcut(.f1, modifiers: {.control}),
  .settings: KeyboardShortcut(.comma, modifiers: {.control}),

  .selectTab1: KeyboardShortcut(.digit1, modifiers: {.control}),
  .selectTab2: KeyboardShortcut(.digit2, modifiers: {.control}),
  .selectTab3: KeyboardShortcut(.digit3, modifiers: {.control}),
  .selectTab4: KeyboardShortcut(.digit4, modifiers: {.control}),
  .selectTab5: KeyboardShortcut(.digit5, modifiers: {.control}),
  .selectTab6: KeyboardShortcut(.digit6, modifiers: {.control}),
  .selectTab7: KeyboardShortcut(.digit7, modifiers: {.control}),
  .selectTab8: KeyboardShortcut(.digit8, modifiers: {.control}),
  .selectTabLast: KeyboardShortcut(.digit9, modifiers: {.control}),

  .newTab: KeyboardShortcut(.keyT, modifiers: {.control, .shift}),
  .closeTab: KeyboardShortcut(.keyW, modifiers: {.control, .shift}),
  .newWindow: KeyboardShortcut(.keyN, modifiers: {.control, .shift}),
  .closeWindow: KeyboardShortcut(.f4, modifiers: {.alt}),

  .undo: KeyboardShortcut(.keyZ, modifiers: {.control}),
  .redo: KeyboardShortcut(.keyY, modifiers: {.control}),
  .cut: KeyboardShortcut(.keyX, modifiers: {.control}),
  .copy: KeyboardShortcut(.keyC, modifiers: {.control}),
  .paste: KeyboardShortcut(.keyV, modifiers: {.control}),
  .selectAll: KeyboardShortcut(.keyA, modifiers: {.control}),

  .terminalCopy: KeyboardShortcut(.keyC, modifiers: {.control, .shift}),
  .terminalPaste: KeyboardShortcut(.keyV, modifiers: {.control, .shift}),

  .zoomIn: KeyboardShortcut(.add, modifiers: {.control}),
  .zoomOut: KeyboardShortcut(.minus, modifiers: {.control}),
  .zoomReset: KeyboardShortcut(.digit0, modifiers: {.control}),
});

/// A default set of keyboard shortcuts for macOS.
final defaultMacShortcuts = KeyboardShortcuts({
  .home: KeyboardShortcut(.f1, modifiers: {.meta}),
  .settings: KeyboardShortcut(.comma, modifiers: {.meta}),

  .selectTab1: KeyboardShortcut(.digit1, modifiers: {.meta}),
  .selectTab2: KeyboardShortcut(.digit2, modifiers: {.meta}),
  .selectTab3: KeyboardShortcut(.digit3, modifiers: {.meta}),
  .selectTab4: KeyboardShortcut(.digit4, modifiers: {.meta}),
  .selectTab5: KeyboardShortcut(.digit5, modifiers: {.meta}),
  .selectTab6: KeyboardShortcut(.digit6, modifiers: {.meta}),
  .selectTab7: KeyboardShortcut(.digit7, modifiers: {.meta}),
  .selectTab8: KeyboardShortcut(.digit8, modifiers: {.meta}),
  .selectTabLast: KeyboardShortcut(.digit9, modifiers: {.meta}),

  .newTab: KeyboardShortcut(.keyT, modifiers: {.meta}),
  .closeTab: KeyboardShortcut(.keyW, modifiers: {.meta}),
  .newWindow: KeyboardShortcut(.keyN, modifiers: {.meta}),
  .closeWindow: KeyboardShortcut(.keyW, modifiers: {.meta, .shift}),

  .undo: KeyboardShortcut(.keyZ, modifiers: {.meta}),
  .redo: KeyboardShortcut(.keyZ, modifiers: {.meta, .shift}),
  .cut: KeyboardShortcut(.keyX, modifiers: {.meta}),
  .copy: KeyboardShortcut(.keyC, modifiers: {.meta}),
  .paste: KeyboardShortcut(.keyV, modifiers: {.meta}),
  .selectAll: KeyboardShortcut(.keyA, modifiers: {.meta}),

  .terminalCopy: KeyboardShortcut(.keyC, modifiers: {.meta}),
  .terminalPaste: KeyboardShortcut(.keyV, modifiers: {.meta}),

  .zoomIn: KeyboardShortcut(.add, modifiers: {.meta}),
  .zoomOut: KeyboardShortcut(.minus, modifiers: {.meta}),
  .zoomReset: KeyboardShortcut(.digit0, modifiers: {.meta}),
});

enum KeyboardShortcutTypeGroup(final List<KeyboardShortcutType> children) {
  tabs([
    .home,
    .settings,
    .selectTab1,
    .selectTab2,
    .selectTab3,
    .selectTab4,
    .selectTab5,
    .selectTab6,
    .selectTab7,
    .selectTab8,
    .selectTabLast,
  ]),
  file([.newTab, .closeTab, .newWindow, .closeWindow]),
  edit([.undo, .redo, .cut, .copy, .paste, .selectAll]),
  terminal([.terminalCopy, .terminalPaste]),
  view([.zoomIn, .zoomOut, .zoomReset]);

  String getDisplayName() {
    return switch (this) {
      .tabs => 'shortcut_group.tabs'.tr(),
      .file => 'shortcut_group.file'.tr(),
      .edit => 'shortcut_group.edit'.tr(),
      .terminal => 'shortcut_group.terminal'.tr(),
      .view => 'shortcut_group.view'.tr(),
    };
  }
}

enum KeyboardShortcutType {
  home,
  settings,

  selectTab1,
  selectTab2,
  selectTab3,
  selectTab4,
  selectTab5,
  selectTab6,
  selectTab7,
  selectTab8,
  selectTabLast,

  // file menu
  newTab,
  closeTab,
  newWindow,
  closeWindow,

  // edit menu
  undo,
  redo,
  cut,
  copy,
  paste,
  selectAll,

  terminalCopy,
  terminalPaste,

  // view menu
  zoomIn,
  zoomOut,
  zoomReset;

  String getDisplayName() {
    return switch (this) {
      .home => 'shortcut.home'.tr(),
      .settings => 'shortcut.settings'.tr(),

      .selectTab1 ||
      .selectTab2 ||
      .selectTab3 ||
      .selectTab4 ||
      .selectTab5 ||
      .selectTab6 ||
      .selectTab7 ||
      .selectTab8 => 'shortcut.select_tab'.tr(
        args: [name.substring(name.length - 1)],
      ),
      .selectTabLast => 'shortcut.select_tab_last'.tr(),

      .newTab => 'shortcut.new_tab'.tr(),
      .closeTab => 'shortcut.close_tab'.tr(),
      .newWindow => 'shortcut.new_window'.tr(),
      .closeWindow => 'shortcut.close_window'.tr(),
      .undo => 'shortcut.undo'.tr(),
      .redo => 'shortcut.redo'.tr(),
      .cut => 'shortcut.cut'.tr(),
      .copy => 'shortcut.copy'.tr(),
      .paste => 'shortcut.paste'.tr(),
      .selectAll => 'shortcut.select_all'.tr(),
      .terminalCopy => 'shortcut.terminal_copy'.tr(),
      .terminalPaste => 'shortcut.terminal_paste'.tr(),
      .zoomIn => 'shortcut.zoom_in'.tr(),
      .zoomOut => 'shortcut.zoom_out'.tr(),
      .zoomReset => 'shortcut.zoom_reset'.tr(),
    };
  }
}

/// A class representing a collection of keyboard shortcuts for various actions.
class KeyboardShortcuts(
  final Map<KeyboardShortcutType, KeyboardShortcut> shortcuts,
) {
  factory fromJson(Map<String, dynamic> json) {
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
      final shortcut = KeyboardShortcut.tryFromJson(entry.value);
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
