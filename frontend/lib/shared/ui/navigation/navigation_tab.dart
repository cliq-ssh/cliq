import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const kMobileItemPadding = EdgeInsets.all(8);

class NavigationTab extends HookConsumerWidget {
  /// The icon widget to display in the sidebar tab.
  final Widget icon;

  /// The label widget to display in the sidebar tab.
  final Widget? label;

  /// Whether the sidebar tab is selected or not.
  final bool selected;

  /// The callback function to execute when the sidebar tab is pressed.
  final VoidCallback? onPress;

  /// Whether to force the tab to have an intrinsic width.
  final bool forceIntrinsicWidth;

  /// An optional padding to apply to the [FSidebarItem].
  final EdgeInsetsGeometry? itemPadding;

  const NavigationTab({
    super.key,
    required this.icon,
    this.label,
    this.selected = false,
    this.onPress,
    this.forceIntrinsicWidth = true,
    this.itemPadding,
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
        padding: itemPadding == null ? null : .value(itemPadding!),
      ),
      label: label,
      icon: IconTheme.merge(data: IconThemeData(size: 20), child: icon),
      selected: selected,
      onPress: onPress,
      initiallyExpanded: true,
    );

    child = forceIntrinsicWidth || selected
        ? IntrinsicWidth(child: child)
        : ConstrainedBox(constraints: .new(maxWidth: 150), child: child);

    return child;
  }
}
