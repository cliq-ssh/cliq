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

    useEffect(() {
      Set<WidgetState> newStates = <WidgetState>{};
      if (isHovered.value) newStates.add(WidgetState.hovered);
      if (disabled || onPressed == null) newStates = {WidgetState.disabled};
      states.value = newStates;

      return null;
    }, [disabled, isHovered.value]);

    return CliqInteractable.fromDefaultWidgetStates(
      states.value,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      onTap: WidgetStateProperty.fromMap({
        WidgetState.disabled: null,
        WidgetState.any: onPressed,
      }).resolve(states.value),
      child: CliqBlurContainer.fromWidgetStateColor(
        states.value,
        style.backgroundColor,
        child: Padding(
          padding: style.padding,
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                IconTheme(
                  data: style.iconTheme.resolve(states.value),
                  child: icon!,
                ),
              CliqDefaultTypography(
                size: textStyle.copyS,
                color: style.iconTheme.resolve(states.value).color,
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
  final WidgetStateColor backgroundColor;
  final WidgetStateProperty<IconThemeData> iconTheme;
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
    final iconTheme = IconThemeData(color: colorScheme.onPrimary, size: 20);
    return CliqButtonStyle(
      backgroundColor: WidgetStateColor.fromMap({
        WidgetState.hovered: colorScheme.onPrimary30,
        WidgetState.disabled: colorScheme.onBackground20,
        WidgetState.any: colorScheme.primary,
      }),
      iconTheme: WidgetStateProperty.fromMap({
        WidgetState.disabled: iconTheme.copyWith(
          color: colorScheme.onBackground70,
        ),
        WidgetState.any: iconTheme,
      }),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
