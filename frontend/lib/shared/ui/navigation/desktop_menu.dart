import 'dart:io';

import 'package:cliq/main.dart';
import 'package:cliq/modules/session/provider/tab.provider.dart';
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

  @override
  void initState() {
    super.initState();

    _windowId = ref.read(currentWindowIdProvider);
    _navigationShell = NavigationShell.of(context);

    if (PlatformUtils.isDesktop && !_isMac) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }

    if (_isMac) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.platformMenuDelegate.setMenus(buildMacOSMenu());
      });
    }

    MultiViewDesktop.setMenuItems([
      .new(title: 'window_new'.tr(), onPressed: _openNewWindow),
      .new(title: 'tab_new'.tr(), onPressed: _openNewTab),
    ]);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  List<PlatformMenuItem> buildMenu() {
    return [_buildFileMenu(prefix: _buildSettingsMenuItem()), _buildEditMenu()];
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
          _buildSettingsMenuItem(),
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
      PlatformMenu(
        label: 'desktop_menu.view'.tr(),
        menus: const [PlatformProvidedMenuItem(type: .toggleFullScreen)],
      ),
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

  /// Returns a platform-specific [SingleActivator] for the given [LogicalKeyboardKey].
  SingleActivator _activator(LogicalKeyboardKey key, {bool shift = false}) {
    return SingleActivator(key, meta: _isMac, control: !_isMac, shift: shift);
  }

  /// Safely invokes an [Intent]
  void _invoke(Intent intent) {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context != null) {
      Actions.maybeInvoke(context, intent);
    }
  }

  PlatformMenuItem _buildSettingsMenuItem() {
    return PlatformMenuItemGroup(
      members: [
        PlatformMenuItem(
          label: 'settings'.tr(),
          shortcut: _activator(.comma),
          onSelected: () => _navigationShell.goToSettingsBranch(),
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
            PlatformMenuItem(
              label: 'tab_new'.tr(),
              shortcut: _activator(.keyT),
              onSelected: _openNewTab,
            ),
            PlatformMenuItem(
              label: 'tab_close'.tr(),
              shortcut: _activator(.keyW),
              onSelected: _closeTab,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'window_new'.tr(),
              shortcut: _activator(.keyN),
              onSelected: _openNewWindow,
            ),
            PlatformMenuItem(
              label: 'window_close'.tr(),
              shortcut: _activator(.keyW, shift: true),
              onSelected: _closeWindow,
            ),
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
            PlatformMenuItem(
              label: 'desktop_menu.undo'.tr(),
              shortcut: _activator(.keyZ),
              onSelected: () => _invoke(const UndoTextIntent(.keyboard)),
            ),
            PlatformMenuItem(
              label: 'desktop_menu.redo'.tr(),
              shortcut: _activator(.keyZ, shift: true),
              onSelected: () => _invoke(const RedoTextIntent(.keyboard)),
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'desktop_menu.cut'.tr(),
              shortcut: _activator(.keyX),
              onSelected: () =>
                  _invoke(const CopySelectionTextIntent.cut(.keyboard)),
            ),
            PlatformMenuItem(
              label: 'desktop_menu.copy'.tr(),
              shortcut: _activator(.keyC),
              onSelected: () => _invoke(CopySelectionTextIntent.copy),
            ),
            PlatformMenuItem(
              label: 'desktop_menu.paste'.tr(),
              shortcut: _activator(.keyV),
              onSelected: () => _invoke(const PasteTextIntent(.keyboard)),
            ),
            PlatformMenuItem(
              label: 'desktop_menu.select_all'.tr(),
              shortcut: _activator(.keyA),
              onSelected: () => _invoke(const SelectAllTextIntent(.keyboard)),
            ),
          ],
        ),
      ],
    );
  }
}
