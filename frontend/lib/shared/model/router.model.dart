import 'package:cliq/modules/connections/page/connections.page.dart';
import 'package:cliq/shared/provider/window_scope.provider.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cliq/shared/ui/tab_page_wrapper.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

class Router {
  static final Map<int, Router> _byWindow = {};

  final Ref ref;
  final int windowId;

  new(this.ref) : windowId = ref.read(currentWindowIdProvider) {
    _byWindow[windowId] = this;
    ref.onDispose(() => _byWindow.remove(windowId));
  }

  final GlobalKey<NavigatorState> rootNavigatorKey = .new(debugLabel: 'root');
  final GlobalKey<NavigatorState> shellNavigatorKey = .new(debugLabel: 'shell');

  late GoRouter goRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => NavigationShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TabPageWrapper.pagePath.path,
                pageBuilder: _fade(const TabPageWrapper()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorKey,
            routes: [
              GoRoute(
                path: ConnectionsPage.pagePath.path,
                pageBuilder: _fade(const ConnectionsPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// Allows to access the [Router] for the currently focused window, determined
  /// by [MultiViewDesktop.isFocused].
  static Router? get focused {
    for (final e in _byWindow.entries) {
      if (MultiViewDesktop.fromId(e.key).isFocused()) return e.value;
    }
    return _byWindow.values.firstOrNull;
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
