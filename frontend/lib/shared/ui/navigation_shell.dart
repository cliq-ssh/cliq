import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/context_menu.dart';
import 'package:cliq/shared/ui/responsive_sidebar.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq_ui/cliq_ui.dart' show useBreakpoint;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/session/provider/session.provider.dart';
import '../../modules/settings/model/navigation_position.model.dart';
import '../../modules/settings/provider/terminal_theme.provider.dart';

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
  static const _sessionBranchIndex = 0;
  static const _dashboardBranchIndex = 1;
  static const _settingsBranchIndex = 2;

  late final ResponsiveSidebarController _sidebarController = .new();

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = useBreakpoint();
    final prefDesktopNavPosition = useStore(.desktopNavigationPosition);
    final navPosition = useState<NavigationPosition>(
      breakpoint >= .lg ? prefDesktopNavPosition.value : .top,
    );
    final connections = ref.watch(connectionProvider);
    final sessions = ref.watch(sessionProvider);
    final terminalTheme = ref.watch(terminalThemeProvider);
    final selectedSession = useState(sessions.selectedSession);
    final showTabs = useState(false);

    useEffect(() {
      selectedSession.value = sessions.selectedSession;
      return null;
    }, [sessions, sessions.selectedSessionId]);

    useEffect(() {
      navPosition.value = breakpoint >= .lg
          ? prefDesktopNavPosition.value
          : .top;
      return null;
    }, [breakpoint, prefDesktopNavPosition.value]);

    /// Gets the effective sidebar color based on the selected session and its terminal theme.
    Color getEffectiveSidebarColor() {
      if (widget.shell.currentIndex == _sessionBranchIndex &&
          selectedSession.value != null &&
          selectedSession.value!.isConnected) {
        final hsl = HSLColor.fromColor(
          (selectedSession.value!.connection.terminalThemeOverride ??
                  terminalTheme.effectiveActiveDefaultTheme)
              .backgroundColor,
        );
        return hsl
            .withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0))
            .toColor();
      }
      return context.theme.colors.background;
    }

    buildDashboardTab(bool isExpanded) {
      // TODO: make shortcut functional
      return FTooltip(
        tipBuilder: (_, _) => TextWithShortCutInfo(
          'Dashboard',
          shortcut: ShortcutActionInfo(.keyD, modifiers: {.control}),
        ),
        child: _buildSidebarTab(
          isExpanded,
          label: Text('Dashboard'),
          icon: Icon(LucideIcons.house, size: 20),
          selected: widget.shell.currentIndex == _dashboardBranchIndex,
          onPress: () {
            ref
                .read(sessionProvider.notifier)
                .setSelectedAndMaybeGo(this, null);
            goToDashboardBranch();
          },
          isTop: navPosition.value == .top,
          noPadding: navPosition.value == .top,
        ),
      );
    }

    buildSettingsTab(bool isExpanded) {
      // TODO: make shortcut functional
      return FTooltip(
        tipBuilder: (_, _) => TextWithShortCutInfo(
          'Settings',
          shortcut: ShortcutActionInfo(.comma, modifiers: {.control}),
        ),
        child: _buildSidebarTab(
          isExpanded,
          label: Text('Settings'),
          icon: Icon(LucideIcons.settings, size: 20),
          selected: widget.shell.currentIndex == _settingsBranchIndex,
          onPress: () {
            ref
                .read(sessionProvider.notifier)
                .setSelectedAndMaybeGo(this, null);
            goToSettingsBranch();
          },
          isTop: navPosition.value == .top,
          noPadding: navPosition.value == .top,
        ),
      );
    }

    buildSessionTabs(bool isExpanded) {
      return [
        for (final session in sessions.activeSessions)
          CustomContextMenu(
            actions: [
              .new(
                label: 'Duplicate',
                icon: LucideIcons.copy,
                onPress: () {
                  ref
                      .read(sessionProvider.notifier)
                      .createAndGo(this, session.connection);
                },
                shortcut: .new(.keyD, modifiers: {.meta}),
              ),
              .new(
                label: 'Close',
                icon: LucideIcons.x,
                onPress: () {
                  ref
                      .read(sessionProvider.notifier)
                      .closeAnyMaybeGo(this, session.id);
                },
                shortcut: .new(.keyW, modifiers: {.alt}),
              ),
            ],
            builder: (_) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return MouseRegion(
                    onEnter: (_) => setState(() {}),
                    onExit: (_) => setState(() {}),
                    child: _buildSidebarTab(
                      isExpanded,
                      label: Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Text(
                              session.connection.label,
                              overflow: .fade,
                              softWrap: false,
                            ),
                          ),
                          FTappable(
                            onPress: () {
                              ref
                                  .read(sessionProvider.notifier)
                                  .closeAnyMaybeGo(this, session.id);
                            },
                            builder: (context, states, child) {
                              final isHovered =
                                  states.contains(FTappableVariant.hovered) ||
                                  states.contains(FTappableVariant.pressed);

                              return Container(
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? context.theme.colors.background
                                      : null,
                                  borderRadius: .circular(8),
                                ),
                                padding: const .all(4),
                                child: child!,
                              );
                            },
                            child: const Icon(LucideIcons.x, size: 16),
                          ),
                        ],
                      ),
                      icon: Builder(
                        builder: (context) {
                          Widget child = Container(
                            decoration: BoxDecoration(
                              color: session.connection.iconBackgroundColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: .all(5),
                            child: Icon(
                              session.connection.icon.iconData,
                              color: session.connection.iconColor,
                              size: 10,
                            ),
                          );

                          if (!isExpanded) {
                            child = AspectRatio(aspectRatio: 1, child: child);
                          }

                          return child;
                        },
                      ),
                      selected: session.id == selectedSession.value?.id,
                      onPress: () => ref
                          .read(sessionProvider.notifier)
                          .setSelectedAndMaybeGo(this, session.id),
                      noPadding: isExpanded,
                      isTop: navPosition.value == .top,
                    ),
                  );
                },
              );
            },
          ),
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
          child: _buildSidebarTab(
            isExpanded && navPosition.value == .left,
            label: Text('New Session'),
            icon: Icon(LucideIcons.plus, size: 20),
            onPress: connections.entities.isNotEmpty
                ? () => showTabs.value = !showTabs.value
                : null,
            isTop: navPosition.value == .top,
            noPadding:
                navPosition.value == .top ||
                (sessions.activeSessions.isNotEmpty && isExpanded),
          ),
        ),
      ];
    }

    if (navPosition.value == .left) {
      return ResponsiveExpandableSidebar(
        controller: _sidebarController,
        backgroundColor: getEffectiveSidebarColor(),
        headerBuilder: (context, isExpanded) {
          return Padding(
            padding: const .symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: !isExpanded ? .center : .spaceBetween,
                  children: [
                    FButton.icon(
                      variant: .outline,
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
            ),
          );
        },
        footerBuilder: (_, isExpanded) => buildSettingsTab(isExpanded),
        contentBuilder: (context, isExpanded) {
          return [
            buildDashboardTab(isExpanded),
            FDivider(style: .delta(color: context.theme.colors.border)),
            if (!isExpanded || sessions.activeSessions.isEmpty)
              ...buildSessionTabs(isExpanded)
            else if (sessions.activeSessions.isNotEmpty)
              FSidebarGroup(
                label: Text('Sessions'),
                children: buildSessionTabs(isExpanded),
              ),
          ];
        },
        child: widget.shell,
      );
    }

    return FScaffold(
      childPad: false,
      header: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: getEffectiveSidebarColor(),
          border: Border(
            bottom: BorderSide(color: context.theme.colors.border, width: 1),
          ),
        ),
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
                      buildDashboardTab(false),
                      ...buildSessionTabs(true),
                    ],
                  ),
                ),
              ),
              buildSettingsTab(false),
            ],
          ),
        ),
      ),
      child: widget.shell,
    );
  }

  static Widget _buildSidebarTab(
    bool isExpanded, {
    Widget? label,
    Widget? icon,
    bool? selected,
    void Function()? onPress,
    bool isTop = false,
    bool noPadding = false,
  }) {
    Widget child = FSidebarItem(
      label: !isExpanded && icon != null ? icon : label,
      icon: isExpanded ? icon : null,
      selected: selected ?? false,
      onPress: onPress,
    );

    if (isTop) {
      child = IntrinsicWidth(child: child);
    }

    return Padding(
      padding: noPadding ? .zero : const .symmetric(horizontal: 16),
      child: child,
    );
  }

  void goToSessionBranch() => _goToBranch(_sessionBranchIndex);
  void goToDashboardBranch() => _goToBranch(_dashboardBranchIndex);
  void goToSettingsBranch() => _goToBranch(_settingsBranchIndex);

  /// Jumps to the corresponding [StatefulShellBranch], based on the specified index.
  void _goToBranch(int index) {
    widget.shell.goBranch(
      index,
      initialLocation: widget.shell.currentIndex == index,
    );
  }
}
