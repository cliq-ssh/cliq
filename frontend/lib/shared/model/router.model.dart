import 'package:cliq/modules/connections/view/connections_page.dart';
import 'package:cliq/modules/session/view/session_page_wrapper.dart';
import 'package:cliq/modules/settings/view/debug_settings_page.dart';
import 'package:cliq/modules/settings/view/identities_settings_page.dart';
import 'package:cliq/modules/settings/view/keys_settings_page.dart';
import 'package:cliq/modules/settings/view/license_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/modules/settings/view/terminal_theme_settings_page.dart';
import 'package:cliq/modules/settings/view/theme_settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../ui/navigation_shell.dart';

class Router {
  final Ref ref;

  Router(this.ref);

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey(
    debugLabel: 'root',
  );
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey(
    debugLabel: 'shell',
  );

  late GoRouter goRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      ..._noShellRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => NavigationShell(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorKey,
            routes: [
              GoRoute(
                path: ConnectionsPage.pagePath.path,
                pageBuilder: _fade(const ConnectionsPage()),
              ),
              ..._shellRoutes(),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SessionPageWrapper.pagePath.path,
                pageBuilder: _fade(const SessionPageWrapper()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  List<GoRoute> _noShellRoutes() {
    return [
      GoRoute(
        path: SettingsPage.pagePath.path,
        pageBuilder: _swipe(const SettingsPage()),
        routes: [
          GoRoute(
            path: DebugSettingsPage.pagePath.path,
            pageBuilder: _swipe(const DebugSettingsPage()),
          ),
          GoRoute(
            path: IdentitiesSettingsPage.pagePath.path,
            pageBuilder: _swipe(const IdentitiesSettingsPage()),
          ),
          GoRoute(
            path: KeysSettingsPage.pagePath.path,
            pageBuilder: _swipe(const KeysSettingsPage()),
          ),
          GoRoute(
            path: LicenseSettingsPage.pagePath.path,
            pageBuilder: _swipe(const LicenseSettingsPage()),
          ),
          GoRoute(
            path: TerminalThemeSettingsPage.pagePath.path,
            pageBuilder: _swipe(const TerminalThemeSettingsPage()),
          ),
          GoRoute(
            path: ThemeSettingsPage.pagePath.path,
            pageBuilder: _swipe(const ThemeSettingsPage()),
          ),
        ],
      ),
    ];
  }

  static List<GoRoute> _shellRoutes() {
    return [];
  }

  static Page<T> Function(BuildContext, GoRouterState) _swipe<T>(Widget child) {
    return (_, _) => CupertinoPage(child: child);
  }

  static Page<T> Function(BuildContext, GoRouterState) _fade<T>(Widget child) {
    return (_, _) => CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}
