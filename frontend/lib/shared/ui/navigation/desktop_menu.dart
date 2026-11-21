import 'dart:io';

import 'package:cliq/main.dart';
import 'package:cliq/modules/session/provider/terminal_zoom.provider.dart';
import 'package:cliq/modules/settings/model/keyboard_shortcuts.model.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/provider/tab.provider.dart';
import 'package:cliq/shared/provider/window_scope.provider.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

class const DesktopMenu({super.key, required final Widget child})
    extends StatefulHookConsumerWidget {
  static DesktopMenuState of(BuildContext context) =>
      context.findAncestorStateOfType<DesktopMenuState>()!;

  @override
  ConsumerState<DesktopMenu> createState() => DesktopMenuState();
}

class DesktopMenuState extends ConsumerState<DesktopMenu> {
  static bool get _isMac => Platform.isMacOS;

  late final int _windowId;
  late final NavigationShellState _navigationShell;

  KeyboardShortcuts _shortcuts = .platformDefaults;
  FocusNode? _lastEditableFocus;

  @override
  void initState() {
    super.initState();

    FocusManager.instance.addListener(_trackFocus);

    _windowId = ref.read(currentWindowIdProvider);
    _navigationShell = NavigationShell.of(context);

    if (PlatformUtils.isDesktop && !_isMac) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }

    MultiViewDesktop.setMenuItems([
      .new(title: 'shortcut.new_window'.tr(), onPressed: _openNewWindow),
      .new(title: 'shortcut.new_tab'.tr(), onPressed: _openNewTab),
    ]);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_trackFocus);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = useStore(.shortcuts);

    _shortcuts = KeyboardShortcuts.merge(.platformDefaults, shortcuts.value);

    if (_isMac) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          WidgetsBinding.instance.platformMenuDelegate.setMenus(
            buildMacOSMenu(),
          );
        }
      });
    }

    return widget.child;
  }

  List<PlatformMenuItem> buildMenu() {
    return [
      _buildFileMenu(prefix: _buildTabsMenuItems()),
      _buildEditMenu(),
      _buildViewMenu(),
    ];
  }

  /// Builds the macOS-specific menu which integrates some more [PlatformProvidedMenuItem]s.
  List<PlatformMenuItem> buildMacOSMenu() {
    return [
      PlatformMenu(
        label: Constants.defaultTitle,
        menus: [
          const PlatformMenuItemGroup(
            members: [PlatformProvidedMenuItem(type: .about)],
          ),
          _buildTabsMenuItems(),
          if (PlatformProvidedMenuItem.hasMenu(.servicesSubmenu))
            const PlatformMenuItemGroup(
              members: [PlatformProvidedMenuItem(type: .servicesSubmenu)],
            ),
          const PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(type: .hide),
              PlatformProvidedMenuItem(type: .hideOtherApplications),
              PlatformProvidedMenuItem(type: .showAllApplications),
            ],
          ),
          const PlatformMenuItemGroup(
            members: [PlatformProvidedMenuItem(type: .quit)],
          ),
        ],
      ),
      _buildFileMenu(),
      _buildEditMenu(),
      _buildViewMenu(showPlatformProvidedItems: true),
      PlatformMenu(
        label: 'desktop_menu.window'.tr(),
        menus: const [
          PlatformProvidedMenuItem(type: .minimizeWindow),
          PlatformProvidedMenuItem(type: .zoomWindow),
          PlatformProvidedMenuItem(type: .arrangeWindowsInFront),
        ],
      ),
    ];
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // Only the focused window should act
    if (_getFocusedWindowId() != _windowId) return false;

    for (final item in _flatten(buildMenu())) {
      final shortcut = item.shortcut;
      if (shortcut is SingleActivator &&
          shortcut.accepts(event, HardwareKeyboard.instance)) {
        item.onSelected?.call();
        return true;
      }
    }
    return false;
  }

  /// Flattens a nested list of [PlatformMenuItem]s into a single list.
  Iterable<PlatformMenuItem> _flatten(Iterable<PlatformMenuItem> items) sync* {
    for (final item in items) {
      if (item is PlatformMenu) {
        yield* _flatten(item.menus);
      } else if (item is PlatformMenuItemGroup) {
        yield* _flatten(item.members);
      } else {
        yield item;
      }
    }
  }

  /// Opens a new tab in the currently focused window.
  /// See [TabNotifier.openNewAndMaybeGo] for more details.
  void _openNewTab() {
    ref
        .read(tabProvider.notifier)
        .openNewAndMaybeGo(
          _navigationShell,
          _getFocusedWindowId() ?? _windowId,
        );
  }

  /// Closes the currently selected tab in the currently focused window.
  /// See [TabNotifier.close] for more details.
  void _closeTab() {
    final selectedTabId = ref
        .read(tabProvider)
        .getSelectedTabIdByWindowId(_getFocusedWindowId() ?? _windowId);
    if (selectedTabId != null) {
      ref.read(tabProvider.notifier).close(selectedTabId);
    }
  }

  /// Opens a new window with the current [windowRoot] as its root widget.
  void _openNewWindow() => openWindow((_, viewId) => windowRoot(viewId));

  /// Closes the currently focused window.
  void _closeWindow() =>
      MultiViewDesktop.fromId(_getFocusedWindowId() ?? _windowId).closeWindow();

  /// Gets the currently focused window id, or null if no window is focused.
  int? _getFocusedWindowId() {
    for (final e in MultiViewDesktop.allWindowViewIds) {
      if (MultiViewDesktop.fromId(e).isFocused()) return e;
    }
    return null;
  }

  void _trackFocus() {
    final node = FocusManager.instance.primaryFocus;
    final ctx = node?.context;
    if (ctx != null &&
        ctx.findAncestorStateOfType<EditableTextState>() != null) {
      _lastEditableFocus = node;
    }
  }

  /// Safely invokes an [Intent] on the currently focused widget
  void _invoke(Intent intent) {
    final node = _lastEditableFocus;
    if (node == null || node.context == null) return;
    node.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = node.context;
      if (ctx != null) Actions.maybeInvoke(ctx, intent);
    });
  }

  void _zoom(void Function(TerminalZoomNotifier n, String sessionId) action) {
    final tabState = ref.read(tabProvider);
    final tabId = tabState.getSelectedTabIdByWindowId(
      _getFocusedWindowId() ?? _windowId,
    );
    final tab = tabState.tabs.where((t) => t.id == tabId).firstOrNull;

    if (tab == null || tab.content != .ssh || tab.sessionId == null) return;
    action(ref.read(terminalZoomProvider.notifier), tab.sessionId!);
  }

  PlatformMenuItem _buildTabsMenuItems() {
    return PlatformMenuItemGroup(
      members: [
        _buildShortcutItem(
          type: .settings,
          onSelected: () => ref
              .read(tabProvider.notifier)
              .openNewAndMaybeGo(
                _navigationShell,
                _windowId,
                content: .settings,
              ),
        ),
        _buildShortcutItem(
          type: .home,
          onSelected: () => _navigationShell.goToDashboardBranch(),
        ),
      ],
    );
  }

  PlatformMenuItem _buildTabSelectionMenu() {
    final List<(int, KeyboardShortcutType)> selectTabTypes = [
      (0, .selectTab1),
      (1, .selectTab2),
      (2, .selectTab3),
      (3, .selectTab4),
      (4, .selectTab5),
      (5, .selectTab6),
      (6, .selectTab7),
      (7, .selectTab8),
      (8, .selectTabLast),
    ];

    return PlatformMenu(
      label: 'shortcut_group.tabs'.tr(),
      menus: [
        for (final type in selectTabTypes)
          _buildShortcutItem(
            type: type.$2,
            onSelected: () {
              final notifier = ref.read(tabProvider.notifier);
              if (type.$1 == 8) {
                notifier.selectLast(_navigationShell, _windowId);
              } else {
                notifier.selectByIndex(_navigationShell, _windowId, type.$1);
              }
            },
          ),
      ],
    );
  }

  PlatformMenuItem _buildFileMenu({PlatformMenuItem? prefix}) {
    return PlatformMenu(
      label: 'desktop_menu.file'.tr(),
      menus: [
        ?prefix,
        PlatformMenuItemGroup(
          members: [
            _buildShortcutItem(type: .newTab, onSelected: _openNewTab),
            _buildShortcutItem(type: .closeTab, onSelected: _closeTab),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            _buildShortcutItem(type: .newWindow, onSelected: _openNewWindow),
            _buildShortcutItem(type: .closeWindow, onSelected: _closeWindow),
          ],
        ),
      ],
    );
  }

  PlatformMenuItem _buildEditMenu() {
    return PlatformMenu(
      label: 'desktop_menu.edit'.tr(),
      menus: [
        PlatformMenuItemGroup(
          members: [
            _buildShortcutItem(
              type: .undo,
              onSelected: () => _invoke(const UndoTextIntent(.keyboard)),
            ),
            _buildShortcutItem(
              type: .redo,
              onSelected: () => _invoke(const RedoTextIntent(.keyboard)),
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            _buildShortcutItem(
              type: .cut,
              onSelected: () =>
                  _invoke(const CopySelectionTextIntent.cut(.keyboard)),
            ),
            _buildShortcutItem(
              type: .copy,
              onSelected: () => _invoke(CopySelectionTextIntent.copy),
            ),
            _buildShortcutItem(
              type: .paste,
              onSelected: () => _invoke(const PasteTextIntent(.keyboard)),
            ),
            _buildShortcutItem(
              type: .selectAll,
              onSelected: () => _invoke(const SelectAllTextIntent(.keyboard)),
            ),
          ],
        ),
      ],
    );
  }

  PlatformMenuItem _buildViewMenu({bool showPlatformProvidedItems = false}) {
    return PlatformMenu(
      label: 'desktop_menu.view'.tr(),
      menus: [
        if (showPlatformProvidedItems)
          const PlatformProvidedMenuItem(type: .toggleFullScreen),
        PlatformMenuItemGroup(
          members: [
            _buildShortcutItem(
              type: .zoomIn,
              onSelected: () => _zoom((n, id) => n.zoomIn(id)),
            ),
            _buildShortcutItem(
              type: .zoomOut,
              onSelected: () => _zoom((n, id) => n.zoomOut(id)),
            ),
            _buildShortcutItem(
              type: .zoomReset,
              onSelected: () => _zoom((n, id) => n.reset(id)),
            ),
          ],
        ),
        PlatformMenuItemGroup(members: [_buildTabSelectionMenu()]),
      ],
    );
  }

  PlatformMenuItem _buildShortcutItem({
    required KeyboardShortcutType type,
    required VoidCallback onSelected,
  }) {
    final shortcut = _shortcuts.shortcuts[type]!;
    return PlatformMenuItem(
      label: type.getDisplayName(),
      shortcut: SingleActivator(
        shortcut.logicalKey,
        shift: shortcut.modifiers.contains(LogicalKeyboardKey.shift),
        control: shortcut.modifiers.contains(LogicalKeyboardKey.control),
        alt: shortcut.modifiers.contains(LogicalKeyboardKey.alt),
        meta: shortcut.modifiers.contains(LogicalKeyboardKey.meta),
      ),
      onSelected: onSelected,
    );
  }
}
