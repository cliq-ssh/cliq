import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/context_menu.dart';
import '../../../shared/ui/navigation/navigation_shell.dart';
import '../../../shared/ui/navigation/navigation_tab.dart';
import '../../../shared/ui/shortcut_info.dart';
import '../model/session.model.dart';
import '../model/tab.model.dart';
import '../provider/session.provider.dart';

class SessionNavigationTab extends HookConsumerWidget {
  /// The root session for this tab.
  /// If this is a single session tab, this will be the only session.
  /// If this is a group tab, this will be the first session in the group.
  final ShellSession root;

  /// The list of sessions in this tab.
  final List<ShellSession> sessions;

  /// Whether this tab is selected or not.
  final bool selected;

  /// The ID of the tab.
  final String? _tabId;

  /// The custom label for the tab. If null, the UI will fall back to the connection label or a generated label based on number of sessions.
  final String? _customLabel;

  SessionNavigationTab(SessionTab tab, {super.key, this.selected = false})
    : root = tab.root,
      sessions = tab.sessions,
      _tabId = tab.id,
      _customLabel = tab.customLabel;

  String get effectiveLabel {
    if (_customLabel != null && _customLabel.isNotEmpty) {
      return _customLabel;
    }

    if (sessions.isEmpty) {
      return root.connection.label;
    }

    return 'session_group_title'.plural(sessions.length + 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDragging = useState(false);
    final isRenaming = useState(false);

    final tabFocusNode = useFocusNode();

    final renameFocusNode = useFocusNode();
    final renameController = useTextEditingController(
      text: root.connection.label,
    );

    select() {
      if (_tabId == null) return;
      ref
          .read(sessionProvider.notifier)
          .setSelectedAndMaybeGo(NavigationShell.of(context), _tabId);
    }

    close() {
      ref
          .read(sessionProvider.notifier)
          .closeTabAndMaybeGo(NavigationShell.of(context), _tabId ?? root.id);
    }

    rename([String? customLabel]) {
      ref
          .read(sessionProvider.notifier)
          .renameTab(_tabId ?? root.id, customLabel);
      renameController.text = (customLabel == null || customLabel.isEmpty)
          ? root.connection.label
          : customLabel;
      isRenaming.value = false;
      tabFocusNode.unfocus();
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
            size: 14,
            padding: 3,
          );

          return child;
        },
      );
    }

    buildLabel() {
      return Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(effectiveLabel, overflow: .fade, softWrap: false),
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
                    color: isHovered ? context.theme.colors.background : null,
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
      );
    }

    buildEditLabel() {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(.escape): rename,
          const SingleActivator(.enter): () {
            rename(renameController.text);
          },
        },
        child: SizedBox(
          width: 150,
          child: FTextField(
            focusNode: renameFocusNode,
            size: .sm,
            control: .managed(controller: renameController),
            autofocus: true,
            onSubmit: (value) => rename(value),
            onEditingComplete: rename,
            onTapOutside: (_) => rename(renameController.text),
            maxLength: 32,
          ),
        ),
      );
    }

    return CustomContextMenu(
      actions: [
        .new(
          label: 'rename'.tr(),
          icon: LucideIcons.penLine,
          onPress: () {
            isRenaming.value = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              renameFocusNode.requestFocus();
            });
          },
        ),
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
        EdgeInsetsGeometry? itemPadding;
        if (PlatformUtils.isMobile) {
          itemPadding = kMobileItemPadding;
        } else if (isRenaming.value) {
          itemPadding = kEditLabelPadding;
        }

        final child = NavigationTab(
          icon: buildIcon(),
          label: isRenaming.value ? buildEditLabel() : buildLabel(),
          selected: selected,
          onPress: select,
          forceIntrinsicWidth: PlatformUtils.isDesktop,
          itemPadding: itemPadding,
          hideFocusOutline: isRenaming.value,
          focusNode: tabFocusNode
        );

        if (sessions.isNotEmpty) {
          return child;
        }

        return Draggable<ShellSession>(
          data: root,
          maxSimultaneousDrags: PlatformUtils.isDesktop && !isRenaming.value
              ? 1
              : 0,
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
