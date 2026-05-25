import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class OptionTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final bool selected;
  final bool dense;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const OptionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.dense = false,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.theme.typography;

    final bgColor = selected
        ? colorScheme.primary.withAlpha((0.08 * 255).round())
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding == EdgeInsets.zero
            ? const EdgeInsets.symmetric(vertical: 8)
            : padding,
        color: bgColor,
        child: Row(
          crossAxisAlignment: subtitle != null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: textTheme.md.copyWith(fontSize: dense ? 14 : 16),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: textTheme.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
