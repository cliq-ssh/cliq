import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const kMobileItemPadding = EdgeInsets.all(8);
const kEditLabelPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);

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

  /// Whether to hide the focus outline when the tab is focused.
  final bool hideFocusOutline;

  /// An optional [FocusNode] to manage focus for the [FSidebarItem].
  /// Mainly used to dismiss the "stuck" focus after editing the session's label.
  final FocusNode? focusNode;

  const NavigationTab({
    super.key,
    required this.icon,
    this.label,
    this.selected = false,
    this.onPress,
    this.forceIntrinsicWidth = true,
    this.itemPadding,
    this.hideFocusOutline = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: if color of session tab page is too similar, add border
    Widget child = FSidebarItem(
      focusNode: focusNode,
      style: .delta(
        backgroundColor: .delta([
          FVariantValueDeltaOperation.base(Colors.transparent),
          FVariantValueDeltaOperation.exact({
            .hovered,
            .selected,
          }, context.theme.colors.card),
        ]),
        padding: itemPadding == null ? null : .value(itemPadding!),
        focusedOutlineStyle: hideFocusOutline
            ? .delta(color: Colors.transparent)
            : null,
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
