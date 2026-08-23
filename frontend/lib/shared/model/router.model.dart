import 'package:cliq/modules/connections/page/connections.page.dart';
import 'package:cliq/modules/session/ui/session_page_wrapper.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/modules/settings/page/views/appearance_settings.view.dart';
import 'package:cliq/modules/settings/page/views/developer_settings.view.dart';
import 'package:cliq/modules/settings/page/views/i18n_settings.view.dart';
import 'package:cliq/modules/settings/page/views/identities_settings.view.dart';
import 'package:cliq/modules/settings/page/views/keys_settings.view.dart';
import 'package:cliq/modules/settings/page/views/known_hosts_settings.view.dart';
import 'package:cliq/modules/settings/page/views/licenses.view.dart';
import 'package:cliq/modules/settings/page/views/shortcuts_settings.view.dart';
import 'package:cliq/modules/settings/page/views/ssh_sftp_settings.view.dart';
import 'package:cliq/modules/settings/page/views/sync_settings.view.dart';
import 'package:cliq/modules/settings/page/views/terminal_theme_settings.view.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Router {
  final Ref ref;

  new(this.ref);

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
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => NavigationShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SessionPageWrapper.pagePath.path,
                pageBuilder: _fade(const SessionPageWrapper()),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SettingsPage.pagePath.path,
                pageBuilder: _fade(const SettingsPage()),
                routes: [
                  GoRoute(
                    path: DeveloperSettingsView.pagePath.path,
                    pageBuilder: _swipe(const DeveloperSettingsView()),
                  ),
                  GoRoute(
                    path: I18nSettingsView.pagePath.path,
                    pageBuilder: _swipe(const I18nSettingsView()),
                  ),
                  GoRoute(
                    path: IdentitiesSettingsView.pagePath.path,
                    pageBuilder: _swipe(const IdentitiesSettingsView()),
                  ),
                  GoRoute(
                    path: KeysSettingsView.pagePath.path,
                    pageBuilder: _swipe(const KeysSettingsView()),
                  ),
                  GoRoute(
                    path: KnownHostsSettingsView.pagePath.path,
                    pageBuilder: _swipe(const KnownHostsSettingsView()),
                  ),
                  GoRoute(
                    path: LicenseSettingsView.pagePath.path,
                    pageBuilder: _swipe(const LicenseSettingsView()),
                  ),
                  GoRoute(
                    path: TerminalThemeSettingsView.pagePath.path,
                    pageBuilder: _swipe(const TerminalThemeSettingsView()),
                  ),
                  GoRoute(
                    path: ShortcutsSettingsView.pagePath.path,
                    pageBuilder: _swipe(const ShortcutsSettingsView()),
                  ),
                  GoRoute(
                    path: SshSftpSettingsView.pagePath.path,
                    pageBuilder: _swipe(const SshSftpSettingsView()),
                  ),
                  GoRoute(
                    path: SyncSettingsView.pagePath.path,
                    pageBuilder: _swipe(const SyncSettingsView()),
                  ),
                  GoRoute(
                    path: AppearanceSettingsView.pagePath.path,
                    pageBuilder: _swipe(const AppearanceSettingsView()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

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
