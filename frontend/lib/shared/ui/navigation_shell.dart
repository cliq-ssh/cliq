import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/shared/ui/responsive_sidebar.dart';
import 'package:cliq/shared/ui/session_tab.dart';
import 'package:cliq_ui/cliq_ui.dart' show useBreakpoint;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/session/provider/session.provider.dart';
import '../../modules/settings/provider/terminal_theme.provider.dart';
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
  late final ResponsiveSidebarController _sidebarController = .new();

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = useBreakpoint();
    final connections = ref.watch(connectionProvider);
    final sessions = ref.watch(sessionProvider);
    final terminalTheme = ref.watch(terminalThemeProvider);
    final selectedSession = useState(sessions.selectedSession);
    final showTabs = useState(false);
    final isHovered = useState<String?>(null);

    useEffect(() {
      selectedSession.value = sessions.selectedSession;
      return null;
    }, [sessions, sessions.selectedSessionId]);

    Color? getEffectiveSidebarColor() {
      if (selectedSession.value != null && selectedSession.value!.isConnected) {
        final color =
            selectedSession
                .value
                ?.connection
                .terminalThemeOverride
                ?.backgroundColor ??
            terminalTheme.effectiveActiveDefaultTheme.backgroundColor;
        // make it a bit darker
        return Color.lerp(color, Colors.black, 0.1);
      }
      return null;
    }

    buildPopoverMenu(Widget child) {
      return FPopoverMenu(
        control: .lifted(
          shown: showTabs.value,
          onChange: (show) => showTabs.value = show,
        ),
        menu: [
          FItemGroup(
            children: [
              for (final connection in connections.entities)
                FItem(
                  title: Text(connection.label),
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
        child: child,
      );
    }

    buildSidebarTab(
      bool isExpanded, {
      Widget? label,
      Widget? icon,
      bool? selected,
      void Function()? onPress,
      void Function(bool)? onHoverChange,
    }) {
      return FSidebarItem(
        label: !isExpanded && icon != null
            ? Row(mainAxisAlignment: .center, children: [icon])
            : label,
        icon: isExpanded ? icon : null,
        selected: selected ?? false,
        onPress: onPress,
        onHoverChange: onHoverChange,
      );
    }

    buildSidebarSessionTabs(bool isExpanded) {
      return [
        for (final session in sessions.activeSessions)
          FTooltip(
            tipBuilder: (_, _) => Text(session.connection.label),
            child: buildSidebarTab(
              isExpanded,
              label: Row(
                children: [
                  Expanded(
                    child: Text(
                      session.connection.label,
                      overflow: .fade,
                      softWrap: false,
                    ),
                  ),
                  if (isHovered.value == session.id) ...[
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(sessionProvider.notifier)
                            .closeSession(this, session.id);
                      },
                      child: Icon(LucideIcons.x, size: 16),
                    ),
                  ],
                ],
              ),
              icon: Container(
                decoration: BoxDecoration(
                  color: session.connection.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: .all(6),
                child: Icon(
                  session.connection.icon.iconData,
                  color: session.connection.iconColor,
                  size: 12,
                ),
              ),
              selected: session.id == selectedSession.value?.id,
              onHoverChange: (hovered) =>
                  isHovered.value = hovered ? session.id : null,
              onPress: () => ref
                  .read(sessionProvider.notifier)
                  .setSelectedSession(this, session.id),
            ),
          ),
        buildPopoverMenu(
          buildSidebarTab(
            isExpanded,
            label: Text('New Session'),
            icon: Icon(LucideIcons.plus, size: 20),
            onPress: connections.entities.isNotEmpty
                ? () => showTabs.value = !showTabs.value
                : null,
          ),
        ),
      ];
    }

    if (breakpoint >= .lg) {
      return ResponsiveExpandableSidebar(
        controller: _sidebarController,
        backgroundColor:
            getEffectiveSidebarColor() ?? context.theme.colors.background,
        padding: const .symmetric(horizontal: 16),
        headerBuilder: (context, isExpanded) {
          return Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: !isExpanded ? .center : .spaceBetween,
                children: [
                  FButton.icon(
                    style: FButtonStyle.ghost(),
                    onPress: _sidebarController.toggle,
                    child: Icon(
                      _sidebarController.isExpanded
                          ? LucideIcons.panelLeftClose
                          : LucideIcons.panelLeftOpen,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        footerBuilder: (context, isExpanded) {
          return buildSidebarTab(
            isExpanded,
            label: Text('Settings'),
            icon: Icon(LucideIcons.settings, size: 20),
            onPress: () => context.pushPath(SettingsPage.pagePath.build()),
          );
        },
        contentBuilder: (context, isExpanded) {
          return [
            buildSidebarTab(
              isExpanded,
              label: Text('Dashboard'),
              icon: Icon(LucideIcons.house, size: 20),
              selected: selectedSession.value == null,
              onPress: () => ref
                  .read(sessionProvider.notifier)
                  .setSelectedSession(this, null),
            ),
            buildSidebarTab(
              isExpanded,
              label: Text('History'),
              icon: Icon(LucideIcons.clock, size: 20),
              onPress: () {}
            ),
            FDivider(style: (_) => context.theme.dividerStyles.horizontalStyle.copyWith(
              color: context.theme.colors.mutedForeground.withValues(alpha: 0.125)
            )),
            if (!isExpanded)
              ...buildSidebarSessionTabs(isExpanded)
            else if (sessions.activeSessions.isNotEmpty)
              FSidebarGroup(
                label: Text('Sessions'),
                children: buildSidebarSessionTabs(isExpanded),
              ),
          ];
        },
        child: widget.shell,
      );
    }

    return FScaffold(
      childPad: false,
      header: Container(
        color: getEffectiveSidebarColor(),
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
                      buildPopoverMenu(
                        FButton.icon(
                          onPress: connections.entities.isNotEmpty
                              ? () => showTabs.value = !showTabs.value
                              : null,
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
