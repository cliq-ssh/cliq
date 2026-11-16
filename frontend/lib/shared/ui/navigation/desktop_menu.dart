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
  late final List<PlatformMenuItem> _menus;

  List<PlatformMenuItem> get menus => _menus;

  @override
  void initState() {
    super.initState();

    final allWindowIds = MultiViewDesktop.allWindowViewIds;
    final windowId = ref.read(currentWindowIdProvider);
    final navigationShell = NavigationShell.of(context);

    invoke(Intent intent) {
      final context = FocusManager.instance.primaryFocus?.context;
      if (context != null) {
        Actions.maybeInvoke(context, intent);
      }
    }

    openNewTab() {
      final focused = allWindowIds.where(
        (id) => id != windowId && MultiViewDesktop.fromId(id).isFocused(),
      );

      ref
          .read(tabProvider.notifier)
          .openNewAndMaybeGo(navigationShell, focused.firstOrNull ?? windowId);
    }

    _menus = [
      PlatformMenu(
        label: Constants.defaultTitle,
        menus: [
          const PlatformMenuItemGroup(
            members: [PlatformProvidedMenuItem(type: .about)],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'settings'.tr(),
                shortcut: _activator(.comma),
                onSelected: () => navigationShell.goToSettingsBranch(),
              ),
            ],
          ),
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

      PlatformMenu(
        label: 'desktop_menu.file'.tr(),
        menus: [
          PlatformMenuItem(
            label: 'new_tab'.tr(),
            shortcut: _activator(.keyT),
            onSelected: openNewTab,
          ),
          PlatformMenuItem(
            label: 'new_window'.tr(),
            shortcut: _activator(.keyN),
            onSelected: _openNewWindow,
          ),
        ],
      ),

      PlatformMenu(
        label: 'desktop_menu.edit'.tr(),
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'desktop_menu.undo'.tr(),
                shortcut: _activator(.keyZ),
                onSelected: () => invoke(const UndoTextIntent(.keyboard)),
              ),
              PlatformMenuItem(
                label: 'desktop_menu.redo'.tr(),
                shortcut: _activator(.keyZ, shift: true),
                onSelected: () => invoke(const RedoTextIntent(.keyboard)),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'desktop_menu.cut'.tr(),
                shortcut: _activator(.keyX),
                onSelected: () =>
                    invoke(const CopySelectionTextIntent.cut(.keyboard)),
              ),
              PlatformMenuItem(
                label: 'desktop_menu.copy'.tr(),
                shortcut: _activator(.keyC),
                onSelected: () => invoke(CopySelectionTextIntent.copy),
              ),
              PlatformMenuItem(
                label: 'desktop_menu.paste'.tr(),
                shortcut: _activator(.keyV),
                onSelected: () => invoke(const PasteTextIntent(.keyboard)),
              ),
              PlatformMenuItem(
                label: 'desktop_menu.select_all'.tr(),
                shortcut: _activator(.keyA),
                onSelected: () => invoke(const SelectAllTextIntent(.keyboard)),
              ),
            ],
          ),
        ],
      ),

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

    if (_isMac) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.platformMenuDelegate.setMenus(_menus);
      });
    }

    MultiViewDesktop.setMenuItems([
      .new(title: 'new_window'.tr(), onPressed: _openNewWindow),
      .new(title: 'new_tab'.tr(), onPressed: openNewTab),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isDesktop) return widget.child;

    // register callbacks independently on windows and linux
    if (!_isMac) {
      return CallbackShortcuts(
        bindings: {
          for (final menu in _menus)
            if (menu.shortcut != null)
              menu.shortcut! as SingleActivator: (menu.onSelected ?? () {}),
        },
        child: Focus(autofocus: true, child: widget.child),
      );
    }

    return widget.child;
  }

  void _openNewWindow() => openWindow((_, viewId) => windowRoot(viewId));

  /// Returns a platform-specific [SingleActivator] for the given [LogicalKeyboardKey].
  SingleActivator _activator(LogicalKeyboardKey key, {bool shift = false}) {
    return SingleActivator(key, meta: _isMac, control: !_isMac, shift: shift);
  }
}
