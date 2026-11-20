import 'dart:io';
import 'dart:math';

import 'package:cliq/modules/settings/model/keyboard_shortcut.model.dart';
import 'package:cliq/shared/provider/file_transfer.provider.dart';
import 'package:cliq/shared/provider/tab.provider.dart';
import 'package:cliq/shared/ui/cliq_tooltip.dart';
import 'package:cliq/shared/ui/navigation/desktop_menu.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/ui/tab_pill.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

const EdgeInsetsGeometry kMacOSNavigationPadding = .only(left: 80);

const _tabGap = 8.0;
const _minTabWidth = 80.0;
const _maxTabWidth = 200.0;
const _arrowWidth = 28.0;

class NavigationShell extends StatefulHookConsumerWidget {
  final StatefulNavigationShell shell;

  const new({super.key, required this.shell});

  static NavigationShellState of(BuildContext context) =>
      context.findAncestorStateOfType<NavigationShellState>()!;

  @override
  ConsumerState<NavigationShell> createState() => NavigationShellState();
}

class NavigationShellState extends ConsumerState<NavigationShell>
    with TickerProviderStateMixin {
  static const _sessionBranchIndex = 0;
  static const _dashboardBranchIndex = 1;

  @override
  Widget build(BuildContext context) {
    final win = MultiViewDesktop.of(context);
    final desktopMenuKey = useMemoized(() => GlobalKey<DesktopMenuState>());
    final isDesktop = PlatformUtils.isDesktop;

    // delayed until post frame
    final menuReady = useState(false);

    final fileTransfer = ref.watch(fileTransferProvider);
    final tabs = ref.watch(tabProvider);
    final windowTabs = tabs.getTabsByWindowId(win.id);
    final previousTabs = usePrevious(windowTabs.length);

    final selectedTabId = tabs.getSelectedTabIdByWindowId(win.id);

    final scrollController = useScrollController();
    final popoverController = useFPopoverController();
    final rotationAnimation = useAnimationController(
      duration: const .new(seconds: 2),
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) menuReady.value = true;
      });
      return null;
    }, const []);

    useEffect(() {
      if (fileTransfer.isAnyPending) {
        rotationAnimation.repeat();
      } else {
        rotationAnimation
          ..stop()
          ..reset();
      }
      return null;
    }, [fileTransfer.pending]);

    // scroll to end when tab is opened
    useEffect(() {
      final grew = previousTabs != null && windowTabs.length > previousTabs;
      if (!grew) return;
      // Wait until the new tab is laid out, otherwise maxScrollExtent is stale
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const .new(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
      return null;
    }, [windowTabs.length]);

    buildMenuTab() {
      final platformMenu = desktopMenuKey.currentState?.buildMenu() ?? [];
      final List<FItemGroupMixin> menu = [];

      for (final item in platformMenu) {
        if (item is! PlatformMenu) continue;

        final groups = _toGroups(item.menus, popoverController);
        if (groups.isEmpty) continue;

        menu.add(
          FItemGroup(
            children: [.submenu(title: Text(item.label), submenu: groups)],
          ),
        );
      }

      return Padding(
        padding: const .only(right: 8),
        child: FPopoverMenu(
          menu: menu,
          arrow: .childCenter,
          control: .managed(controller: popoverController),
          builder: (context, controller, _) {
            return FButton.icon(
              variant: .ghost,
              onPress: controller.toggle,
              child: const Icon(LucideIcons.menu),
            );
          },
        ),
      );
    }

    buildNewTabButton() {
      return CliqTooltip(
        text: TextWithShortcutInfo(
          'shortcut.new_tab'.tr(),
          shortcut: KeyboardShortcut(.keyT, modifiers: {.meta}),
        ),
        child: FButton.icon(
          variant: .ghost,
          child: const Icon(LucideIcons.plus),
          onPress: () =>
              ref.read(tabProvider.notifier).openNewAndMaybeGo(this, win.id),
        ),
      );
    }

    toggleMaximize() {
      if (win.isMaximized()) {
        win.unmaximize();
      } else {
        win.maximize();
      }
    }

    buildCustomNavigationButtons() {
      buildButton({
        required VoidCallback onPress,
        required IconData icon,
        bool flipX = false,
      }) {
        return FButton.icon(
          size: .sm,
          variant: .ghost,
          onPress: onPress,
          child: Transform.flip(flipX: true, child: Icon(icon, size: 14)),
        );
      }

      return Padding(
        padding: const .only(left: 8),
        child: Row(
          children: [
            buildButton(onPress: () => win.minimize(), icon: LucideIcons.minus),
            buildButton(
              onPress: () async => await toggleMaximize(),
              icon: LucideIcons.copy,
            ),
            buildButton(
              onPress: () => win.closeWindow(),
              flipX: true,
              icon: LucideIcons.x,
            ),
          ],
        ),
      );
    }

    buildScrollArrow({
      required Function(ScrollPosition) enabledWhen,
      required VoidCallback onPress,
      required Widget icon,
    }) {
      return SizedBox(
        width: _arrowWidth,
        child: ListenableBuilder(
          listenable: scrollController,
          builder: (context, _) {
            final enabled =
                scrollController.positions.length == 1 &&
                scrollController.position.hasContentDimensions &&
                enabledWhen(scrollController.position);

            return FButton.icon(
              size: .xs,
              variant: .ghost,
              onPress: enabled ? onPress : null,
              child: icon,
            );
          },
        ),
      );
    }

    buildTabList() {
      return Flexible(
        child: SizedBox(
          height: 34,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final count = max(1, windowTabs.length);
              final fullTabWidth = (constraints.maxWidth / count - _tabGap)
                  .clamp(_minTabWidth, _maxTabWidth);
              final overflows =
                  windowTabs.length * (fullTabWidth + _tabGap) >
                  constraints.maxWidth + 0.5;

              final tabWidth = overflows
                  ? _minTabWidth // overflow only happens once tabs hit the minimum
                  : fullTabWidth;
              final step = (tabWidth + _tabGap) * 3;

              final contentWidth = windowTabs.length * (tabWidth + _tabGap);
              final listWidth = overflows
                  ? constraints.maxWidth - 2 * _arrowWidth
                  : min(constraints.maxWidth, contentWidth);

              void scrollBy(double delta) {
                final pos = scrollController.position;
                scrollController.animateTo(
                  (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }

              return Row(
                mainAxisSize: .min,
                children: [
                  if (overflows)
                    buildScrollArrow(
                      icon: const Icon(LucideIcons.chevronLeft),
                      enabledWhen: (pos) => pos.pixels > 0.5,
                      onPress: () => scrollBy(-step),
                    ),
                  SizedBox(
                    key: const ValueKey('tab_list'),
                    width: listWidth,
                    child: ReorderableListView.builder(
                      scrollController: scrollController,
                      scrollDirection: .horizontal,
                      itemExtentBuilder: (index, _) {
                        final tab = windowTabs[index];
                        if (tab.pinned) {
                          // pinned tabs are always full-size
                          return _maxTabWidth;
                        }
                        return tabWidth + _tabGap;
                      },
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, _, _) => child,
                      itemCount: windowTabs.length,
                      onReorderItem: (from, to) =>
                          ref.read(tabProvider.notifier).reorder(from, to),
                      itemBuilder: (context, index) {
                        final tab = windowTabs[index];

                        return ReorderableDragStartListener(
                          key: ValueKey(tab.id),
                          index: index,
                          child: Padding(
                            padding: const .only(right: _tabGap),
                            child: TabPill(
                              tab: tab,
                              selected:
                                  tab.id == selectedTabId &&
                                  widget.shell.currentIndex ==
                                      _sessionBranchIndex,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (overflows)
                    buildScrollArrow(
                      icon: const Icon(LucideIcons.chevronRight),
                      enabledWhen: (pos) =>
                          pos.pixels < pos.maxScrollExtent - 0.5,
                      onPress: () => scrollBy(step),
                    ),
                ],
              );
            },
          ),
        ),
      );
    }

    buildHeader() {
      return Container(
        constraints: const .new(minHeight: 54 - 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.theme.colors.border, width: 1),
          ),
        ),
        child: Stack(
          children: [
            if (PlatformUtils.isDesktop)
              Positioned.fill(
                child: DragToMoveArea(
                  child: GestureDetector(
                    behavior: .opaque,
                    onDoubleTap: () => toggleMaximize(),
                  ),
                ),
              ),

            Padding(
              padding:
                  (Platform.isMacOS ? kMacOSNavigationPadding : EdgeInsets.zero)
                      .add(const .all(8)),
              child: FTooltipGroup(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (isDesktop && !Platform.isMacOS) buildMenuTab(),
                          Padding(
                            padding: const .only(right: _tabGap),
                            child: CliqTooltip(
                              text: Text('dashboard'.tr()),
                              child: FButton.icon(
                                variant: .ghost,
                                selected:
                                    widget.shell.currentIndex ==
                                    _dashboardBranchIndex,
                                onPress: goToDashboardBranch,
                                child: const Icon(LucideIcons.home),
                              ),
                            ),
                          ),
                          buildTabList(),
                          buildNewTabButton(),
                        ],
                      ),
                    ),
                    if (isDesktop && !Platform.isMacOS)
                      buildCustomNavigationButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    buildFooter() {
      if (isDesktop) return null;
      return FBottomNavigationBar(
        index: widget.shell.currentIndex - 1,
        onChange: (index) {
          final _ = switch (index + 1) {
            _dashboardBranchIndex => goToDashboardBranch(),
            _ => throw UnimplementedError(),
          };
        },
        children: [
          FBottomNavigationBarItem(
            icon: const Icon(LucideIcons.layoutDashboard),
            label: Text('dashboard'.tr()),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(LucideIcons.settings),
            label: Text('settings'.tr()),
          ),
        ],
      );
    }

    return DesktopMenu(
      key: desktopMenuKey,
      child: FScaffold(
        childPad: false,
        resizeToAvoidBottomInset: false,
        header: buildHeader(),
        footer: buildFooter(),
        child: widget.shell,
      ),
    );
  }

  void goToSessionBranch() => _goToBranch(_sessionBranchIndex);
  void goToDashboardBranch() => _goToBranch(_dashboardBranchIndex);

  /// Jumps to the corresponding [StatefulShellBranch], based on the specified index.
  void _goToBranch(int index) {
    widget.shell.goBranch(
      index,
      initialLocation: widget.shell.currentIndex == index,
    );
  }

  List<FItemGroupMixin> _toGroups(
    List<PlatformMenuItem> items,
    FPopoverController popoverController,
  ) {
    final List<FItemGroupMixin> groups = [];
    final List<PlatformMenuItem> loose = [];

    void flush() {
      final children = _toItems(loose, popoverController);
      loose.clear();
      if (children.isNotEmpty) groups.add(.group(children: children));
    }

    for (final i in items) {
      if (i is PlatformMenuItemGroup) {
        flush();
        loose.addAll(i.members);
        flush();
      } else {
        loose.add(i);
      }
    }
    flush();
    return groups;
  }

  List<FItemMixin> _toItems(
    List<PlatformMenuItem> items,
    FPopoverController popoverController,
  ) {
    return [
      for (final i in items)
        ?switch (i) {
          PlatformProvidedMenuItem() || PlatformMenuItemGroup() => null,
          PlatformMenu() => .submenu(
            title: Text(i.label),
            submenu: _toGroups(i.menus, popoverController),
          ),
          _ => .item(
            title: i.shortcut == null
                ? Text(i.label)
                : TextWithShortcutInfo(
                    i.label,
                    shortcut: .fromSingleActivator(
                      i.shortcut! as SingleActivator,
                    ),
                    spaceBetween: true,
                  ),
            onPress: () {
              i.onSelected?.call();
              popoverController.hide();
            },
          ),
        },
    ];
  }
}
