import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/provider/tab.provider.dart';
import 'package:cliq/shared/ui/hover_builder.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

class const TabPill({
  super.key,
  required final Tab tab,
  final bool selected = false,
}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final win = MultiViewDesktop.of(context);

    final cardStyleDecoration =
        context.theme.cardStyle.decoration as ShapeDecoration;
    final popoverController = useFPopoverController();

    final renameController = useTextEditingController(
      text: tab.getEffectiveLabel(context),
    );
    final renameFocusNode = useFocusNode();
    final isRenaming = useState(false);

    select() {
      popoverController.hide();
      ref
          .read(tabProvider.notifier)
          .select(NavigationShell.of(context), win.id, tab.id);
    }

    pin({bool unpin = false}) {
      popoverController.hide();
      ref.read(tabProvider.notifier).pin(tab.id, unpin: unpin);
    }

    rename() {
      popoverController.hide();
      isRenaming.value = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        renameFocusNode.requestFocus();
      });
    }

    renameComplete() {
      ref
          .read(tabProvider.notifier)
          .rename(tab.id, renameController.text.trim());
      isRenaming.value = false;
    }

    close() {
      popoverController.hide();
      ref.read(tabProvider.notifier).close(tab.id);
    }

    buildPopoverMenu({required Widget child}) {
      return FPopoverMenu(
        menu: [
          .group(
            children: [
              if (!tab.pinned)
                .item(title: Text('tab_pin'.tr()), onPress: pin)
              else
                .item(
                  title: Text('tab_unpin'.tr()),
                  onPress: () => pin(unpin: true),
                ),
              .item(title: Text('tab_rename'.tr()), onPress: rename),
            ],
          ),
          .group(
            children: [.item(title: Text('tab_close'.tr()), onPress: close)],
          ),
        ],
        control: .managed(controller: popoverController),
        arrow: .childCenter,
        child: child,
      );
    }

    buildEditableText() {
      return SizedBox(
        width: 160,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(.enter): renameComplete,
            const SingleActivator(.numpadEnter): renameComplete,
            const SingleActivator(.escape): () => isRenaming.value = false,
          },
          child: IntrinsicWidth(
            child: EditableText(
              controller: renameController,
              focusNode: renameFocusNode,
              style: context.theme.typography.body.sm,
              cursorColor: context.theme.colors.primary,
              backgroundCursorColor: context.theme.colors.background,
              selectAllOnFocus: true,
              onTapOutside: (_) => isRenaming.value = false,
            ),
          ),
        ),
      );
    }

    return buildPopoverMenu(
      child: FTappable(
        onPress: select,
        onSecondaryPress: () =>
            isRenaming.value ? null : popoverController.toggle(),
        child: GestureDetector(
          onTertiaryTapUp: (_) => tab.pinned ? null : close(),
          child: HoverBuilder(
            builder: (context, isHovered) {
              return Container(
                decoration: BoxDecoration(
                  color: selected ? cardStyleDecoration.color : null,
                  borderRadius: cardStyleDecoration.borderRadius?.subtract(
                    const .all(.circular(4)),
                  ),
                  border: .fromBorderSide(
                    (cardStyleDecoration.shape as OutlinedBorder).side,
                  ),
                ),
                constraints: const .new(minWidth: 100, maxWidth: 200),
                child: Padding(
                  padding: const .only(left: 12, right: 4),
                  child: Row(
                    mainAxisSize: .min,
                    mainAxisAlignment: .spaceBetween,
                    spacing: 12,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: .min,
                          spacing: 8,
                          children: [
                            if (tab.pinned)
                              const Icon(LucideIcons.pin, size: 16),
                            Flexible(
                              child: isRenaming.value
                                  ? buildEditableText()
                                  : Text(
                                      tab.getEffectiveLabel(context),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      if (!isRenaming.value &&
                          !tab.pinned &&
                          (selected || isHovered))
                        FButton.icon(
                          size: .xs,
                          variant: .ghost,
                          onPress: close,
                          child: const Icon(LucideIcons.x),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
