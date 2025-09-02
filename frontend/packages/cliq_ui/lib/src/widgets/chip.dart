import 'package:flutter/cupertino.dart';

import 'package:cliq_ui/cliq_ui.dart';

class CliqChip extends StatelessWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final CliqChipStyle? style;

  const CliqChip({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.chipStyle;

    return CliqInteractable(
      onTap: onTap,
      child: CliqBlurContainer(
        borderRadius: style.borderRadius,
        child: Padding(
          padding: style.padding,
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null)
                IconTheme(data: style.iconStyle, child: leading!),
              if (title != null)
                CliqDefaultTypography(
                  size: context.theme.typography.copyS,
                  color: context.theme.colorScheme.onSecondaryBackground,
                  fontFamily: CliqFontFamily.secondary,
                  child: title!,
                ),
              if (trailing != null)
                IconTheme(data: style.iconStyle, child: trailing!),
            ],
          ),
        ),
      ),
    );
  }
}

final class CliqChipStyle {
  final IconThemeData iconStyle;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  const CliqChipStyle({
    required this.iconStyle,
    required this.borderRadius,
    required this.padding,
  });

  factory CliqChipStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqChipStyle(
      iconStyle: IconThemeData(
        color: colorScheme.onSecondaryBackground,
        size: 16,
      ),
      borderRadius: BorderRadius.circular(48),
      padding: const EdgeInsets.all(8),
    );
  }
}
