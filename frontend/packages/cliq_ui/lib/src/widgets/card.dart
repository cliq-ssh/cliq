import 'package:flutter/cupertino.dart';

import 'package:cliq_ui/cliq_ui.dart';

class CliqCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final Widget? child;
  final CliqCardStyle? style;

  const CliqCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.cardStyle;
    final typography = context.theme.typography;
    final colorScheme = context.theme.colorScheme;

    return CliqInteractable(
      onTap: onTap,
      child: CliqBlurContainer(
        borderRadius: style.borderRadius,
        child: Padding(
          padding: style.padding,
          child: Row(
            children: [
              if (leading != null)
                IconTheme(data: style.iconStyle, child: leading!),
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      CliqDefaultTypography(
                        size: typography.h5,
                        color: colorScheme.onSecondaryBackground,
                        child: title!,
                      ),
                    if (subtitle != null)
                      CliqDefaultTypography(
                        size: typography.copyS,
                        color: colorScheme.onSecondaryBackground70,
                        child: subtitle!,
                      ),
                    if (child != null) ...[
                      const SizedBox(height: 8),
                      CliqDefaultTypography(
                        size: typography.copyM,
                        color: colorScheme.onSecondaryBackground,
                        child: child!,
                      ),
                    ],
                  ],
                ),
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

final class CliqCardStyle {
  final IconThemeData iconStyle;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  const CliqCardStyle({
    required this.iconStyle,
    required this.borderRadius,
    required this.padding,
  });

  factory CliqCardStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqCardStyle(
      iconStyle: IconThemeData(
        color: colorScheme.onSecondaryBackground,
        size: 24,
      ),
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
    );
  }
}
