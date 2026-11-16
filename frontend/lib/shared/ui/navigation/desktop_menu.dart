import 'dart:io';

import 'package:cliq/main.dart';
import 'package:cliq/modules/session/provider/tab.provider.dart';
import 'package:cliq/shared/provider/window_scope.provider.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
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
    final windowId = ref.read(currentWindowIdProvider);

    openNewTab() => ref
        .read(tabProvider.notifier)
        .openNewAndMaybeGo(NavigationShell.of(context), windowId);

    _menus = [
      .new(
        label: 'new_tab'.tr(),
        shortcut: _activator(.keyT),
        onSelected: openNewTab,
      ),
      .new(
        label: 'new_window'.tr(),
        shortcut: _activator(.keyN),
        onSelected: _openNewWindow,
      ),
    ];

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

    return PlatformMenuBar(menus: menus, child: widget.child);
  }

  void _openNewWindow() => openWindow((_, viewId) => windowRoot(viewId));

  /// Returns a platform-specific [SingleActivator] for the given [LogicalKeyboardKey].
  SingleActivator _activator(LogicalKeyboardKey key) {
    return SingleActivator(key, meta: _isMac, control: !_isMac);
  }
}
