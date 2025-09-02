import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

// TODO: - hover state
// TODO: - disabled state

class CliqButton extends StatelessWidget {
  final Widget label;
  final Widget? icon;
  final Function()? onPressed;
  final bool reverse;
  final CliqButtonStyle? style;

  const CliqButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.reverse = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.buttonStyle;
    final textStyle = context.theme.typography;

    return CliqInteractable(
      onTap: onPressed,
      child: CliqBlurContainer(
        color: style.backgroundColor,
        outlineColor: style.iconTheme.color!.withValues(alpha: .3),
        child: Padding(
          padding: style.padding,
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) IconTheme(data: style.iconTheme, child: icon!),
              CliqDefaultTypography(
                size: textStyle.copyS,
                color: style.iconTheme.color,
                fontFamily: CliqFontFamily.secondary,
                child: label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class CliqButtonStyle {
  final Color backgroundColor;
  final IconThemeData iconTheme;
  final EdgeInsetsGeometry padding;

  const CliqButtonStyle({
    required this.backgroundColor,
    required this.iconTheme,
    required this.padding,
  });

  factory CliqButtonStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqButtonStyle(
      backgroundColor: colorScheme.primary,
      iconTheme: IconThemeData(color: colorScheme.onPrimary, size: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
