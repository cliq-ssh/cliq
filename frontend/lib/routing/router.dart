import 'package:cliq/modules/hosts/view/hosts_page.dart';
import 'package:cliq/modules/history/view/history_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/routing/ui/navbar_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppRouter {
  final Ref<Object?> ref;

  AppRouter(this.ref);

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey(
    debugLabel: 'root',
  );
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey(
    debugLabel: 'shell',
  );

  late GoRouter goRouter = GoRouter(
    initialLocation: '/hosts',
    navigatorKey: rootNavigatorKey,
    routes: [
      ..._noShellRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => NavigationShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorKey,
            routes: [
              GoRoute(
                path: HostsPage.pagePath.path,
                pageBuilder: _defaultBranchPageBuilder(const HostsPage()),
              ),
              ..._shellRoutes(),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HistoryPage.pagePath.path,
                pageBuilder: _defaultBranchPageBuilder(const HistoryPage()),
              ),
              ..._shellRoutes(),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SettingsPage.pagePath.path,
                pageBuilder: _defaultBranchPageBuilder(const SettingsPage()),
              ),
              ..._shellRoutes(),
            ],
          ),
        ],
      ),
    ],
  );

  List<GoRoute> _noShellRoutes() {
    return [];
  }

  static List<GoRoute> _shellRoutes() {
    return [];
  }

  static Page<T> _buildDefaultPageTransition<T>(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CupertinoPage(child: child);
  }

  static Page<T> Function(BuildContext, GoRouterState) _defaultPageBuilder<T>(
      Widget child,
      ) {
    return (context, state) =>
        _buildDefaultPageTransition(context, state, child);
  }

  static Page<T> Function(BuildContext, GoRouterState)
  _defaultBranchPageBuilder<T>(Widget child) {
    return (context, state) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}
