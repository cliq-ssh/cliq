import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/modules/settings/model/navigation_position.model.dart';
import 'package:cliq/shared/ui/sidebar_tab.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/context_menu.dart';
import '../../../shared/ui/navigation_shell.dart';
import '../../../shared/ui/shortcut_info.dart';
import '../model/session.model.dart';
import '../model/tab.model.dart';
import '../provider/session.provider.dart';

class SessionSidebarTab extends HookConsumerWidget {
  /// The root session for this tab.
  /// If this is a single session tab, this will be the only session.
  /// If this is a group tab, this will be the first session in the group.
  final ShellSession root;

  /// The list of sessions in this tab.
  final List<ShellSession> sessions;

  /// Whether this tab is expanded or not. If true, the label will be displayed in addition to the icon.
  final bool isExpanded;

  /// The position of the navigation bar.
  final NavigationPosition navPosition;

  /// Whether this tab is selected or not.
  final bool selected;

  /// The ID of the tab.
  final String? tabId;

  SessionSidebarTab.single(
    ShellSession session, {
    super.key,
    required this.isExpanded,
    required this.navPosition,
    this.selected = false,
  }) : root = session,
       sessions = [],
       tabId = null;

  SessionSidebarTab.tab(
    SessionTab tab, {
    super.key,
    required this.isExpanded,
    required this.navPosition,
    this.selected = false,
  }) : root = tab.root,
       sessions = tab.sessions,
       tabId = tab.id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDragging = useState(false);

    select() {
      if (tabId == null) return;
      ref
          .read(sessionProvider.notifier)
          .setSelectedAndMaybeGo(NavigationShell.of(context), tabId);
    }

    close() {
      ref
          .read(sessionProvider.notifier)
          .closeTabAndMaybeGo(NavigationShell.of(context), tabId ?? root.id);
    }

    buildIcon() {
      if (sessions.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(LucideIcons.layoutPanelLeft, size: 14),
        );
      }

      return Builder(
        builder: (context) {
          Widget child = ConnectionIcon.fromConnection(
            root.connection,
            size: navPosition == .left && !isExpanded ? 16 : 14,
            padding: 3,
          );

          if (!isExpanded) {
            child = AspectRatio(aspectRatio: 1, child: child);
          }

          return child;
        },
      );
    }

    return CustomContextMenu(
      actions: [
        if (sessions.isEmpty)
          .new(
            label: 'duplicate'.tr(),
            icon: LucideIcons.copy,
            onPress: () {
              ref
                  .read(sessionProvider.notifier)
                  .createAndGo(NavigationShell.of(context), root.connection);
            },
            shortcut: .new(.keyD, modifiers: {.meta}),
          ),
        .new(
          label: sessions.isEmpty ? 'close'.tr() : 'close_all'.tr(),
          icon: LucideIcons.x,
          variant: .destructive,
          onPress: close,
          shortcut: .new(.keyW, modifiers: {.alt}),
        ),
      ],
      builder: (_) {
        final child = SidebarTab(
          isExpanded: isExpanded,
          label: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  sessions.isEmpty
                      ? root.connection.label
                      : 'session_group_title'.plural(sessions.length + 1),
                  overflow: .fade,
                  softWrap: false,
                ),
              ),
              // TODO: make shortcut functional
              FTooltip(
                tipBuilder: (_, _) => TextWithShortcutInfo(
                  sessions.isEmpty ? 'close'.tr() : 'close_all'.tr(),
                  shortcut: KeyboardShortcut(.keyW, modifiers: {.control}),
                ),
                child: FTappable(
                  onPress: close,
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
                      padding: const .symmetric(horizontal: 4),
                      child: child!,
                    );
                  },
                  child: const Icon(LucideIcons.x, size: 16),
                ),
              ),
            ],
          ),
          icon: buildIcon(),
          selected: selected,
          onPress: select,
          forceIntrinsicWidth: PlatformUtils.isDesktop,
          noHorizontalPadding: isExpanded,
          isTop: navPosition == .top,
          itemPadding: PlatformUtils.isMobile ? kMobileItemPadding : null,
        );

        if (!isExpanded || sessions.isNotEmpty) {
          return child;
        }

        return Draggable<ShellSession>(
          data: root,
          maxSimultaneousDrags: PlatformUtils.isDesktop ? 1 : 0,
          onDragStarted: () => isDragging.value = true,
          onDragEnd: (_) => isDragging.value = false,
          onDraggableCanceled: (_, _) => isDragging.value = false,
          onDragCompleted: () => isDragging.value = false,
          onDragUpdate: (_) => isDragging.value = true,
          feedback: SizedBox(
            width: 200,
            child: Opacity(
              opacity: 0.7,
              child: IgnorePointer(ignoring: true, child: child),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: IgnorePointer(ignoring: true, child: child),
          ),
          child: IgnorePointer(ignoring: isDragging.value, child: child),
        );
      },
    );
  }
}
