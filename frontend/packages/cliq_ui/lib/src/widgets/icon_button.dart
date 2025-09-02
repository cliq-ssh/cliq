import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

// TODO: - hover state
// TODO: - disabled state
// TODO: - haptic feedback

class CliqIconButton extends StatelessWidget {
  final Widget icon;
  final Widget? label;
  final Function()? onPressed;
  final bool reverse;
  final CliqIconButtonStyle? style;

  const CliqIconButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.reverse = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.iconButtonStyle;
    final textStyle = context.theme.typography;

    return CliqInteractable(
      onTap: onPressed,
      child: CliqBlurContainer(
        child: Padding(
          padding: style.padding,
          child: StatefulBuilder(
            builder: (_, _) {
              final List<Widget> items = [
                IconTheme(data: style.iconTheme, child: icon),
                if (label != null)
                  CliqDefaultTypography(
                    size: textStyle.copyS,
                    color: style.iconTheme.color,
                    fontFamily: CliqFontFamily.secondary,
                    child: label!,
                  ),
              ];

              return Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: reverse ? items.reversed.toList() : items,
              );
            },
          ),
        ),
      ),
    );
  }
}

final class CliqIconButtonStyle {
  final IconThemeData iconTheme;
  final EdgeInsetsGeometry padding;

  const CliqIconButtonStyle({required this.iconTheme, required this.padding});

  factory CliqIconButtonStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqIconButtonStyle(
      iconTheme: IconThemeData(
        color: colorScheme.onSecondaryBackground,
        size: 20,
      ),
      padding: const EdgeInsets.all(12),
    );
  }
}
