import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/shared/data/sqlite/database.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/session/provider/session.provider.dart';

class NavigationShell extends StatefulHookConsumerWidget {
  final StatefulNavigationShell shell;

  const NavigationShell({super.key, required this.shell});

  static NavigationShellState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<NavigationShellState>();

  @override
  ConsumerState<NavigationShell> createState() => NavigationShellState();
}

class NavigationShellState extends ConsumerState<NavigationShell>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final connections = useState<List<Connection>>([]);
    final sessions = ref.watch(sessionProvider);
    final popoverController = useFPopoverController(vsync: this);

    useEffect(() {
      CliqDatabase.connectionsRepository.findAll().then(
        (data) => connections.value = data,
      );
      return null;
    }, []);

    return FScaffold(
      header: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          spacing: 8,
          children: [
            FButton.icon(
              onPress: () => ref
                  .read(sessionProvider.notifier)
                  .setSelectedSession(context, null),
              child: Icon(LucideIcons.house),
            ),
            for (final session in sessions.activeSessions)
              GestureDetector(
                onTap: () => ref
                    .read(sessionProvider.notifier)
                    .setSelectedSession(context, session.id),
                child: FBadge(
                  style: sessions.selectedSessionId == session.id
                      ? FBadgeStyle.primary()
                      : FBadgeStyle.outline(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      spacing: 8,
                      children: [
                        if (session.connectionState ==
                            ShellSessionConnectionState.connecting)
                          FCircularProgress(),
                        if (session.connectionState ==
                            ShellSessionConnectionState.connected)
                          Icon(LucideIcons.circleSmall),
                        if (session.connectionState ==
                            ShellSessionConnectionState.disconnected)
                          Icon(LucideIcons.unplug),
                        Text(session.effectiveName),
                      ],
                    ),
                  ),
                ),
              ),
            FPopoverMenu(
              popoverController: popoverController,
              menu: [
                FItemGroup(
                  children: [
                    for (final connection in connections.value)
                      FItem(
                        title: Text(connection.address),
                        onPress: () {
                          ref
                              .read(sessionProvider.notifier)
                              .createAndGo(context, connection);
                          popoverController.hide();
                        },
                      ),
                  ],
                ),
              ],
              builder: (_, controller, _) => FButton.icon(
                onPress: controller.toggle,
                child: Icon(LucideIcons.plus),
              ),
            ),
          ],
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
