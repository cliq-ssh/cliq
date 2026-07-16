import 'dart:io';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../modules/session/provider/session.provider.dart';
import '../../../modules/session/ui/session_navigation_tab.dart';
import '../../../modules/settings/provider/terminal_theme.provider.dart';
import '../../provider/file_transfer.provider.dart';
import '../../utils/text_utils.dart';
import 'navigation_tab.dart';

const EdgeInsetsGeometry kMacOSNavigationPadding = .only(left: 70);

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

  @override
  Widget build(BuildContext context) {
    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final applyTerminalThemeColorToNavigation = useStore(
      .applyTerminalThemeColorToNavigation,
    );
    final connections = ref.watch(connectionProvider);
    final sessions = ref.watch(sessionProvider);
    final terminalThemes = ref.watch(terminalThemeProvider);
    final selectedTab = useState(sessions.selectedSession);
    final showTabs = useState(false);

    final fileTransfer = ref.watch(fileTransferProvider);

    final rotationAnimation = useAnimationController(
      duration: const .new(seconds: 2),
    );
    final isDesktop = PlatformUtils.isDesktop;

    useEffect(() {
      selectedTab.value = sessions.selectedSession;
      return null;
    }, [sessions, sessions.selectedTabId]);

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

    connect(ConnectionFull connection, {bool isSftp = false}) {
      ref
          .read(sessionProvider.notifier)
          .createAndGo(this, connection, isSftp: isSftp);
      showTabs.value = false;
    }

    /// Gets the effective sidebar color based on the selected session and its terminal theme.
    Color getEffectiveSidebarColor() {
      if (applyTerminalThemeColorToNavigation.value &&
          widget.shell.currentIndex == _sessionBranchIndex &&
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

    buildDashboardTab() {
      // TODO: make shortcut functional
      return FTooltip(
        tipBuilder: (_, _) => TextWithShortcutInfo(
          'dashboard'.tr(),
          shortcut: KeyboardShortcut(.keyD, modifiers: {.control}),
        ),
        child: NavigationTab(
          icon: Icon(LucideIcons.house),
          selected: widget.shell.currentIndex == _dashboardBranchIndex,
          onPress: () {
            ref
                .read(sessionProvider.notifier)
                .setSelectedAndMaybeGo(this, null);
            goToDashboardBranch();
          },
        ),
      );
    }

    buildQueue() {
      return FPopover(
        popoverBuilder: (context, controller) {
          // latest transfer on top
          final items = fileTransfer.pending.entries.toList()
            ..sort((a, b) => b.value.startTime.compareTo(a.value.startTime));

          return Container(
            width: 300,
            constraints: .new(maxHeight: 400),
            child: FTileGroup(
              divider: .full,
              children: [
                if (fileTransfer.isEmpty)
                  FTile(title: Text('queue_empty'.tr()))
                else
                  for (final item in items)
                    FTile(
                      title: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                item.value.file.fileName,
                                softWrap: false,
                              ),
                            ),
                          ),
                          if (item.value.isInProgress)
                            Text(
                              '${(item.value.progressData.progress * 100).toStringAsFixed(1)}%',
                              style: context.theme.typography.body.xs.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                        ],
                      ),
                      subtitle: SizedBox(
                        width: 300,
                        child: Builder(
                          builder: (context) {
                            if (item.value.isInProgress) {
                              return Padding(
                                padding: const .symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: .start,
                                  spacing: 8,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: FDeterminateProgress(
                                        value: item.value.progressData.progress,
                                      ),
                                    ),
                                    Row(
                                      spacing: 8,
                                      mainAxisAlignment: .spaceBetween,
                                      children: [
                                        Text(
                                          '${TextUtils.formatBytes(item.value.progressData.currentBytes) ?? '--'} / ${TextUtils.formatBytes(item.value.progressData.totalBytes) ?? '--'}',
                                        ),
                                        if (item
                                                .value
                                                .progressData
                                                .bytesPerSecond !=
                                            null)
                                          Text(
                                            '${TextUtils.formatDuration(item.value.progressData.estimatedSecondsRemaining!)}, ${TextUtils.formatBytes(item.value.progressData.bytesPerSecond!) ?? '--'}/s',
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (item.value.error != null) {
                              return Text(
                                item.value.error!,
                                style: context.theme.typography.body.xs
                                    .copyWith(
                                      color: context.theme.colors.destructive,
                                    ),
                              );
                            }

                            final seconds =
                                DateTime.fromMillisecondsSinceEpoch(
                                      item.value.endTime!,
                                    )
                                    .difference(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        item.value.startTime,
                                      ),
                                    )
                                    .inSeconds;
                            return Text(
                              'completed in ${TextUtils.formatDuration(seconds)}',
                            );
                          },
                        ),
                      ),
                      suffix: FButton.icon(
                        variant: item.value.tempFile != null
                            ? .destructive
                            : .ghost,
                        child: Icon(
                          item.value.tempFile != null
                              ? LucideIcons.trash
                              : LucideIcons.x,
                        ),
                        onPress: () {
                          final fileTransferNotifier = ref.read(
                            fileTransferProvider.notifier,
                          );
                          if (item.value.isInProgress) {
                            fileTransferNotifier.cancel(context, item.key);
                          } else {
                            fileTransferNotifier.remove(item.key);
                          }
                        },
                      ),
                    ),
              ],
            ),
          );
        },
        builder: (_, controller, _) {
          return NavigationTab(
            icon: RotationTransition(
              turns: rotationAnimation,
              child: Icon(
                fileTransfer.isEmpty
                    ? LucideIcons.refreshCwOff
                    : LucideIcons.refreshCw,
              ),
            ),
            onPress: fileTransfer.isEmpty ? null : controller.toggle,
          );
        },
      );
    }

    buildSettingsTab() {
      // TODO: make shortcut functional
      return FTooltip(
        tipBuilder: (_, _) => TextWithShortcutInfo(
          'settings'.tr(),
          shortcut: KeyboardShortcut(.comma, modifiers: {.control}),
        ),
        child: NavigationTab(
          icon: Icon(LucideIcons.settings),
          selected: widget.shell.currentIndex == _settingsBranchIndex,
          onPress: () {
            ref
                .read(sessionProvider.notifier)
                .setSelectedAndMaybeGo(this, null);
            goToSettingsBranch();
          },
        ),
      );
    }

    buildNewSessionTab() {
      return FTooltip(
        tipBuilder: (_, _) => TextWithShortcutInfo(
          'session_new'.tr(),
          shortcut: KeyboardShortcut(.keyT, modifiers: {.meta}),
        ),
        child: NavigationTab(
          icon: Icon(LucideIcons.plus),
          onPress: connections.entities.isNotEmpty
              ? () => showTabs.value = !showTabs.value
              : null,
          itemPadding: PlatformUtils.isMobile ? kMobileItemPadding : null,
        ),
      );
    }

    buildSessionSidebarTabs() {
      return [
        for (final tab in sessions.activeTabs)
          SessionNavigationTab(tab, selected: tab.id == selectedTab.value?.id),
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
                    prefix: ConnectionIcon.fromConnection(
                      connection,
                      size: 10,
                      padding: 5,
                    ),
                    suffix: FTooltipGroup(
                      child: Row(
                        mainAxisSize: .min,
                        spacing: 4,
                        children: [
                          FTooltip(
                            tipBuilder: (_, _) =>
                                Text('hosts_connect_sftp'.tr()),
                            child: FButton.icon(
                              size: .xs,
                              child: Icon(LucideIcons.folder, size: 12),
                              onPress: () => connect(connection, isSftp: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(connection.label),
                    onPress: () => connect(connection),
                  ),
              ],
            ),
          ],
          child: buildNewSessionTab(),
        ),
      ];
    }

    toggleMaximize() async {
      final isMaximized = await windowManager.isMaximized();
      if (isMaximized) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
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
            buildButton(
              onPress: () async => await windowManager.minimize(),
              icon: LucideIcons.minus,
            ),
            buildButton(
              onPress: () async => await toggleMaximize(),
              icon: LucideIcons.copy,
            ),
            buildButton(
              onPress: () async => await windowManager.close(),
              flipX: true,
              icon: LucideIcons.x,
            ),
          ],
        ),
      );
    }

    return FScaffold(
      childPad: false,
      resizeToAvoidBottomInset: false,
      header: Container(
        constraints: .new(minHeight: 54 - 16),
        decoration: BoxDecoration(
          color: getEffectiveSidebarColor(),
          border: Border(
            bottom: BorderSide(color: context.theme.colors.border, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () async => await toggleMaximize(),
                  onPanStart: (_) => windowManager.startDragging(),
                ),
              ),

              Padding(
                padding:
                    (Platform.isMacOS
                            ? kMacOSNavigationPadding
                            : EdgeInsets.zero)
                        .add(.all(8)),
                child: FTooltipGroup(
                  child: Row(
                    children: [
                      Expanded(
                        // TODO: implement ReorderableListView for session tabs
                        child: SingleChildScrollView(
                          hitTestBehavior: .translucent,
                          scrollDirection: .horizontal,
                          child: Row(
                            spacing: 8,
                            children: [
                              if (isDesktop) buildDashboardTab(),
                              ...buildSessionSidebarTabs(),
                            ],
                          ),
                        ),
                      ),
                      if (isDesktop && fileTransfer.isNotEmpty) buildQueue(),
                      if (isDesktop) buildSettingsTab(),
                      if (isDesktop && !Platform.isMacOS)
                        buildCustomNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      footer: isDesktop
          ? null
          : FBottomNavigationBar(
              style: .delta(
                decoration: .boxDelta(color: getEffectiveSidebarColor()),
              ),
              index: widget.shell.currentIndex - 1,
              onChange: (index) {
                final _ = switch (index + 1) {
                  _dashboardBranchIndex => goToDashboardBranch(),
                  _settingsBranchIndex => goToSettingsBranch(),
                  _ => throw UnimplementedError(),
                };
              },
              children: [
                FBottomNavigationBarItem(
                  icon: Icon(LucideIcons.house),
                  label: Text('dashboard'.tr()),
                ),
                FBottomNavigationBarItem(
                  icon: Icon(LucideIcons.settings),
                  label: Text('settings'.tr()),
                ),
              ],
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
