import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/responsive_sidebar.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/ui/sidebar_tab.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart' show useBreakpoint;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/session/provider/session.provider.dart';
import '../../modules/session/ui/session_sidebar_tab.dart';
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
    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final navPosition = useState<NavigationPosition>(
      breakpoint >= .lg ? prefDesktopNavPosition.value : .top,
    );
    final connections = ref.watch(connectionProvider);
    final sessions = ref.watch(sessionProvider);
    final terminalThemes = ref.watch(terminalThemeProvider);
    final selectedTab = useState(sessions.selectedSession);
    final showTabs = useState(false);

    useEffect(() {
      selectedTab.value = sessions.selectedSession;
      return null;
    }, [sessions, sessions.selectedTabId]);

    useEffect(() {
      navPosition.value = breakpoint >= .lg
          ? prefDesktopNavPosition.value
          : .top;
      return null;
    }, [breakpoint, prefDesktopNavPosition.value]);

    /// Gets the effective sidebar color based on the selected session and its terminal theme.
    Color getEffectiveSidebarColor() {
      if (widget.shell.currentIndex == _sessionBranchIndex &&
          selectedTab.value != null &&
          selectedTab.value!.isAnyConnected) {
        return selectedTab.value!.getEffectiveSidebarColor(
          context,
          terminalThemes,
          defaultTerminalTheme.value,
        );
      }
      return context.theme.colors.background;
    }

    buildDashboardTab(bool isExpanded) {
      // TODO: make shortcut functional
      return FTooltip(
        tipBuilder: (_, _) => TextWithShortcutInfo(
          'Dashboard',
          shortcut: KeyboardShortcut(.keyD, modifiers: {.control}),
        ),
        child: SidebarTab(
          isExpanded: isExpanded,
          label: Text('Dashboard'),
          icon: Icon(LucideIcons.house),
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
        tipBuilder: (_, _) => TextWithShortcutInfo(
          'Settings',
          shortcut: KeyboardShortcut(.comma, modifiers: {.control}),
        ),
        child: SidebarTab(
          isExpanded: isExpanded,
          label: Text('Settings'),
          icon: Icon(LucideIcons.settings),
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

    buildSessionSidebarTabs(bool isExpanded) {
      return [
        for (final tab in sessions.activeTabs)
          SessionSidebarTab.tab(
            tab,
            isExpanded: isExpanded,
            navPosition: navPosition.value,
            selected: tab.id == selectedTab.value?.id,
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
          child: SidebarTab(
            isExpanded: isExpanded && navPosition.value == .left,
            label: Text('New Session'),
            icon: Icon(LucideIcons.plus),
            onPress: connections.entities.isNotEmpty
                ? () => showTabs.value = !showTabs.value
                : null,
            isTop: navPosition.value == .top,
            noPadding:
                navPosition.value == .top ||
                (sessions.activeTabs.isNotEmpty && isExpanded),
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
            if (!isExpanded || sessions.activeTabs.isEmpty)
              ...buildSessionSidebarTabs(isExpanded)
            else if (sessions.activeTabs.isNotEmpty)
              FSidebarGroup(
                label: Text('Sessions'),
                children: buildSessionSidebarTabs(isExpanded),
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
                      ...buildSessionSidebarTabs(true),
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
