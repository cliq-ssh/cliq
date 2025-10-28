import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/routing/router.extension.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NavigationShell extends StatefulHookConsumerWidget {
  final StatefulNavigationShell shell;

  const NavigationShell({super.key, required this.shell});

  static NavigationShellState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<NavigationShellState>();

  @override
  ConsumerState<NavigationShell> createState() => NavigationShellState();
}

class NavigationShellState extends ConsumerState<NavigationShell> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        suffixes: [
          FButton.icon(child: Icon(LucideIcons.search), onPress: () {}),
          FButton.icon(
            child: Icon(LucideIcons.settings),
            onPress: () => context.pushPath(SettingsPage.pagePath.build()),
          ),
        ],
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
