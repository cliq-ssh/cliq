import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CliqButton extends HookWidget {
  final Widget label;
  final Widget? icon;
  final Function()? onPressed;
  final bool reverseOrder;
  final bool disabled;
  final CliqButtonStyle? style;

  const CliqButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.reverseOrder = false,
    this.disabled = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.buttonStyle;
    final textStyle = context.theme.typography;
    final isHovered = useState(false);
    final states = useState<Set<WidgetState>>({});

    final colorStates = WidgetStateColor.fromMap({
      WidgetState.hovered: style.hoveredBackgroundColor,
      WidgetState.disabled: style.disabledBackgroundColor,
      WidgetState.any: style.backgroundColor,
    });

    final iconThemeStates = WidgetStateProperty.fromMap({
      WidgetState.disabled: style.disabledIconTheme,
      WidgetState.any: style.iconTheme,
    });

    useEffect(() {
      Set<WidgetState> newStates = <WidgetState>{};
      if (isHovered.value) newStates.add(WidgetState.hovered);
      if (disabled || onPressed == null) newStates = {WidgetState.disabled};
      states.value = newStates;

      return null;
    }, [disabled, isHovered.value]);

    return CliqInteractable(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      onTap: WidgetStateProperty.fromMap({
        WidgetState.disabled: null,
        WidgetState.any: onPressed,
      }).resolve(states.value),
      cursor: WidgetStateProperty.fromMap({
        WidgetState.disabled: SystemMouseCursors.forbidden,
        WidgetState.any: SystemMouseCursors.click,
      }).resolve(states.value),
      disableAnimation: states.value.contains(WidgetState.disabled),
      child: CliqBlurContainer(
        color: colorStates.resolve(states.value),
        outlineColor: CliqColorScheme.calculateOutlineColor(
          colorStates.resolve(states.value),
        ),
        child: Padding(
          padding: style.padding,
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                IconTheme(
                  data: iconThemeStates.resolve(states.value),
                  child: icon!,
                ),
              CliqDefaultTypography(
                size: textStyle.copyS,
                color: iconThemeStates.resolve(states.value).color,
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
  final Color hoveredBackgroundColor;
  final Color disabledBackgroundColor;
  final IconThemeData iconTheme;
  final IconThemeData disabledIconTheme;
  final EdgeInsetsGeometry padding;

  const CliqButtonStyle({
    required this.backgroundColor,
    required this.hoveredBackgroundColor,
    required this.disabledBackgroundColor,
    required this.iconTheme,
    required this.disabledIconTheme,
    required this.padding,
  });

  factory CliqButtonStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    final iconTheme = IconThemeData(color: colorScheme.onPrimary, size: 20);
    return CliqButtonStyle(
      backgroundColor: colorScheme.primary,
      hoveredBackgroundColor: colorScheme.onPrimary20,
      disabledBackgroundColor: colorScheme.onBackground20,
      iconTheme: iconTheme,
      disabledIconTheme: iconTheme.copyWith(color: colorScheme.onBackground70),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
