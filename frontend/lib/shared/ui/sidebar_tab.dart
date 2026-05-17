import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SidebarTab extends HookConsumerWidget {
  final Widget? label;
  final Widget? icon;
  final bool? selected;
  final void Function()? onPress;
  final bool isExpanded;
  final bool isTop;
  final bool noPadding;

  const SidebarTab({
    super.key,
    this.label,
    this.icon,
    this.selected,
    this.onPress,
    this.isExpanded = false,
    this.isTop = false,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: if color of session tab page is too similar, add border

    Widget child = FSidebarItem(
      style: .delta(
        backgroundColor: .delta([
          FVariantValueDeltaOperation.base(Colors.transparent),
          FVariantValueDeltaOperation.exact({
            .hovered,
            .selected,
          }, context.theme.colors.card),
        ]),
      ),
      label: !isExpanded && icon != null ? icon : label,
      icon: isExpanded
          ? IconTheme.merge(data: IconThemeData(size: 20), child: icon!)
          : null,
      selected: selected ?? false,
      onPress: onPress,
      initiallyExpanded: true,
    );

    if (isTop) {
      child = IntrinsicWidth(child: child);
    }

    return Padding(
      padding: noPadding ? .zero : const .symmetric(horizontal: 16),
      child: child,
    );
  }
}
