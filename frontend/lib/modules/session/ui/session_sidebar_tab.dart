import 'package:cliq/modules/settings/model/navigation_position.model.dart';
import 'package:cliq/shared/ui/sidebar_tab.dart';
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
  final ShellSession root;
  final List<ShellSession> sessions;
  final bool isExpanded;
  final NavigationPosition navPosition;
  final bool selected;
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
          Widget child = Container(
            decoration: BoxDecoration(
              color: root.connection.iconBackgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: .all(5),
            child: Icon(
              root.connection.icon.iconData,
              color: root.connection.iconColor,
              size: 10,
            ),
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
            label: 'Duplicate',
            icon: LucideIcons.copy,
            onPress: () {
              ref
                  .read(sessionProvider.notifier)
                  .createAndGo(NavigationShell.of(context), root.connection);
            },
            shortcut: .new(.keyD, modifiers: {.meta}),
          ),
        .new(
          label: sessions.isEmpty ? 'Close' : 'Close All',
          icon: LucideIcons.x,
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
                      : '${sessions.length + 1} sessions',
                  overflow: .fade,
                  softWrap: false,
                ),
              ),
              // TODO: make shortcut functional
              FTooltip(
                tipBuilder: (_, _) => TextWithShortCutInfo(
                  sessions.isEmpty ? 'Close' : 'Close All',
                  shortcut: ShortcutActionInfo(.keyW, modifiers: {.control}),
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
                      padding: const .all(4),
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
          noPadding: isExpanded,
          isTop: navPosition == .top,
        );

        if (!isExpanded || sessions.isNotEmpty) {
          return child;
        }

        return Draggable<ShellSession>(
          data: root,
          maxSimultaneousDrags: 1,
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
