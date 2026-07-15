import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const kMobileItemPadding = EdgeInsets.all(8);

class SidebarTab extends HookConsumerWidget {
  /// The icon widget to display in the sidebar tab.
  final Widget icon;

  /// The label widget to display in the sidebar tab.
  final Widget? label;

  /// Whether the sidebar tab is selected or not.
  final bool selected;

  /// The callback function to execute when the sidebar tab is pressed.
  final VoidCallback? onPress;

  /// Whether this tab is expanded or not. If true, the label will be displayed in addition to the icon.
  final bool isExpanded;

  /// Whether this tab is on the top navigation bar in a horizontal-scrollable list.
  /// This wraps the tab in an [IntrinsicWidth] widget to prevent it from stretching to fill the available width.
  final bool isTop;

  /// Whether to force the tab to have an intrinsic width.
  final bool forceIntrinsicWidth;

  /// Whether to remove the horizontal padding around the tab. If true, the tab will have no horizontal padding.
  final bool noHorizontalPadding;

  /// An optional padding to apply to the [FSidebarItem].
  final EdgeInsetsGeometry? itemPadding;

  const SidebarTab({
    super.key,
    required this.icon,
    this.label,
    this.selected = false,
    this.onPress,
    this.isExpanded = false,
    this.isTop = false,
    this.forceIntrinsicWidth = false,
    this.noHorizontalPadding = false,
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
      label: !isExpanded ? icon : label,
      icon: isExpanded
          ? IconTheme.merge(data: IconThemeData(size: 20), child: icon)
          : null,
      selected: selected,
      onPress: onPress,
      initiallyExpanded: true,
    );

    if (isTop) {
      child = forceIntrinsicWidth || selected
          ? IntrinsicWidth(child: child)
          : ConstrainedBox(constraints: .new(maxWidth: 150), child: child);
    }

    return Padding(
      padding: noHorizontalPadding ? .zero : const .symmetric(horizontal: 16),
      child: child,
    );
  }
}
