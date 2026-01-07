import 'package:cliq/modules/connections/extension/connection.extension.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/shared/ui/session_tab.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/session/provider/session.provider.dart';
import '../../modules/settings/view/settings_page.dart';
import '../extensions/router.extension.dart';

class NavigationShell extends StatefulHookConsumerWidget {
  final StatefulNavigationShell shell;

  const NavigationShell({super.key, required this.shell});

  static NavigationShellState of(BuildContext context) =>
      context.findAncestorStateOfType<NavigationShellState>()!;

  @override
  ConsumerState<NavigationShell> createState() => NavigationShellState();
}

class NavigationShellState extends ConsumerState<NavigationShell>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(connectionProvider);
    final sessions = ref.watch(sessionProvider);
    final selectedSession = useState(sessions.selectedSession);
    final showTabs = useState(false);

    useEffect(() {
      selectedSession.value = sessions.selectedSession;
      return null;
    }, [sessions, sessions.selectedSessionId]);

    return FScaffold(
      childPad: false,
      header: Container(
        color:
            selectedSession.value != null && selectedSession.value!.isConnected
            // TODO: get color from session
            ? TerminalColorThemes.darcula.backgroundColor
            : null,
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                // TODO: implement ReorderableListView for session tabs
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: [
                      FButton.icon(
                        style: widget.shell.currentIndex == 0
                            ? FButtonStyle.primary()
                            : FButtonStyle.outline(),
                        onPress: () => ref
                            .read(sessionProvider.notifier)
                            .setSelectedSession(this, null),
                        child: Icon(LucideIcons.house),
                      ),
                      for (final session in sessions.activeSessions)
                        SessionTab(session: session),
                      FPopoverMenu(
                        control: .lifted(
                          shown: showTabs.value,
                          onChange: (show) => showTabs.value = show,
                        ),
                        menu: [
                          FItemGroup(
                            children: [
                              for (final connection in connections.entities)
                                FItem(
                                  title: Text(connection.effectiveName),
                                  onPress: () {
                                    ref
                                        .read(sessionProvider.notifier)
                                        .createAndGo(this, connection);
                                    showTabs.value = false;
                                  },
                                ),
                            ],
                          ),
                        ],
                        child: FButton.icon(
                          onPress: () => showTabs.value = !showTabs.value,
                          child: Icon(LucideIcons.plus),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FButton.icon(
                child: Icon(LucideIcons.settings),
                onPress: () => context.pushPath(SettingsPage.pagePath.build()),
              ),
            ],
          ),
        ),
      ),
      child: widget.shell,
    );
  }

  void refresh() => setState(() {});

  /// Simply checks whether there are two or more slashes in the current path.
  bool canPop() {
    final GoRouterState state = GoRouterState.of(context);
    return (state.fullPath ?? state.matchedLocation).characters
            .where((p0) => p0 == '/')
            .length >=
        2;
  }

  /// Resets the current branch. Useful for popping an unknown amount of pages.
  void resetLocation({int? index}) {
    widget.shell.goBranch(
      index ?? widget.shell.currentIndex,
      initialLocation: true,
    );
  }

  /// Jumps to the corresponding [StatefulShellBranch], based on the specified index.
  void goToBranch(int index) {
    widget.shell.goBranch(
      index,
      initialLocation: widget.shell.currentIndex == index,
    );
  }
}
