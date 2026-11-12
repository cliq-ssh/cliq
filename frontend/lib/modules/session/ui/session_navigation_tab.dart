import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/settings/model/keyboard_shortcut.model.dart';
import 'package:cliq/shared/ui/cliq_tooltip.dart';
import 'package:cliq/shared/ui/context_menu.dart';
import 'package:cliq/shared/ui/navigation/navigation_tab.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const SessionNavigationTab({
  super.key,
  required final ShellSession session,

  /// Whether this tab is selected or not
  final bool selected = false,
}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRenaming = useState(false);

    final tabFocusNode = useFocusNode();

    final renameFocusNode = useFocusNode();
    final renameController = useTextEditingController(
      text: session.connection.label,
    );

    final effectiveLabel = session.getEffectiveTitle(context);

    select() {}

    close() {
      ref.read(sessionProvider.notifier).remove(session.id);
    }

    rename([String? customLabel]) {
      ref.read(sessionProvider.notifier).rename(session.id, customLabel);

      renameController.text = session.getEffectiveTitle(context);
      isRenaming.value = false;
      tabFocusNode.unfocus();
    }

    buildIcon() {
      return Builder(
        builder: (context) {
          final ConnectionIcon child = .fromConnection(
            session.connection,
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
          CliqTooltip(
            text: TextWithShortcutInfo(
              'close'.tr(),
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
                  child: child,
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
        .new(
          label: 'duplicate'.tr(),
          icon: LucideIcons.copy,
          onPress: () {
            // TODO: implement
          },
          shortcut: .new(.keyD, modifiers: {.meta}),
        ),
        .new(
          label: 'close'.tr(),
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

        return CliqTooltip(
          text: Text(effectiveLabel),
          child: NavigationTab(
            icon: buildIcon(),
            label: isRenaming.value ? buildEditLabel() : buildLabel(),
            selected: selected,
            onPress: select,
            forceIntrinsicWidth: PlatformUtils.isDesktop,
            itemPadding: itemPadding,
            hideFocusOutline: isRenaming.value,
            focusNode: tabFocusNode,
          ),
        );
      },
    );
  }
}
