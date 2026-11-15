import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/provider/tab.provider.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

class const TabPill({
  super.key,
  required final Tab tab,
  final bool selected = false,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final win = MultiViewDesktop.of(context);
    final cardStyleDecoration =
        context.theme.cardStyle.decoration as ShapeDecoration;

    select() {
      ref
          .read(tabProvider.notifier)
          .select(NavigationShell.of(context), win.id, tab.id);
    }

    close() {
      ref.read(tabProvider.notifier).close(tab.id);
    }

    return FTappable(
      onPress: select,
      child: GestureDetector(
        onTertiaryTapUp: (_) => close(),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? cardStyleDecoration.color : null,
            borderRadius: cardStyleDecoration.borderRadius?.subtract(
              const .all(.circular(4)),
            ),
            border: .fromBorderSide(
              (cardStyleDecoration.shape as OutlinedBorder).side,
            ),
          ),
          constraints: const .new(minWidth: 120),
          padding: .symmetric(vertical: selected ? 4 : 7),
          child: Padding(
            padding: const .only(left: 12, right: 2),
            child: Row(
              spacing: 12,
              mainAxisSize: .min,
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(tab.getEffectiveLabel(context)),
                if (selected)
                  FButton.icon(
                    size: .xs,
                    variant: .ghost,
                    child: const Icon(LucideIcons.x),
                    onPress: () => ref.read(tabProvider.notifier).close(tab.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
