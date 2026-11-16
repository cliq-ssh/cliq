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

    if (_isMac) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.platformMenuDelegate.setMenus(buildMacOSMenu());
      });
    }

    MultiViewDesktop.setMenuItems([
      .new(title: 'new_window'.tr(), onPressed: _openNewWindow),
      .new(title: 'new_tab'.tr(), onPressed: _openNewTab),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isDesktop) return widget.child;

    // register callbacks independently on windows and linux
    if (!_isMac) {
      return CallbackShortcuts(
        bindings: {
          for (final menu in buildMenu())
            if (menu.shortcut != null)
              menu.shortcut! as SingleActivator: (menu.onSelected ?? () {}),
        },
        child: Focus(autofocus: true, child: widget.child),
      );
    }

    return widget.child;
  }

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

  /// Opens a new tab in the currently focused window.
  /// See [TabNotifier.openNewAndMaybeGo] for more details.
  void _openNewTab() {
    final allWindowIds = MultiViewDesktop.allWindowViewIds;
    final focused = allWindowIds.where(
      (id) => id != _windowId && MultiViewDesktop.fromId(id).isFocused(),
    );

    ref
        .read(tabProvider.notifier)
        .openNewAndMaybeGo(_navigationShell, focused.firstOrNull ?? _windowId);
  }

  /// Opens a new window with the current [windowRoot] as its root widget.
  void _openNewWindow() => openWindow((_, viewId) => windowRoot(viewId));

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
        PlatformMenuItem(
          label: 'new_tab'.tr(),
          shortcut: _activator(.keyT),
          onSelected: _openNewTab,
        ),
        PlatformMenuItem(
          label: 'new_window'.tr(),
          shortcut: _activator(.keyN),
          onSelected: _openNewWindow,
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
