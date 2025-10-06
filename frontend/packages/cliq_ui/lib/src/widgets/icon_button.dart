import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CliqIconButton extends HookWidget {
  final Widget icon;
  final Widget? label;
  final Function()? onPressed;
  final bool reverseOrder;
  final bool disabled;
  final CliqIconButtonStyle? style;

  const CliqIconButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.reverseOrder = false,
    this.disabled = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.iconButtonStyle;
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
          child: StatefulBuilder(
            builder: (_, _) {
              final List<Widget> items = [
                IconTheme(
                  data: iconThemeStates.resolve(states.value),
                  child: icon,
                ),
                if (label != null)
                  CliqDefaultTypography(
                    size: textStyle.copyS,
                    color: iconThemeStates.resolve(states.value).color,
                    fontFamily: CliqFontFamily.secondary,
                    child: label!,
                  ),
              ];

              return Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: reverseOrder ? items.reversed.toList() : items,
              );
            },
          ),
        ),
      ),
    );
  }
}

final class CliqIconButtonStyle {
  final Color backgroundColor;
  final Color hoveredBackgroundColor;
  final Color disabledBackgroundColor;
  final IconThemeData iconTheme;
  final IconThemeData disabledIconTheme;
  final EdgeInsetsGeometry padding;

  const CliqIconButtonStyle({
    required this.backgroundColor,
    required this.hoveredBackgroundColor,
    required this.disabledBackgroundColor,
    required this.iconTheme,
    required this.disabledIconTheme,
    required this.padding,
  });

  factory CliqIconButtonStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    final iconTheme = IconThemeData(
      color: colorScheme.onSecondaryBackground,
      size: 20,
    );
    return CliqIconButtonStyle(
      backgroundColor: colorScheme.secondaryBackground50,
      hoveredBackgroundColor: colorScheme.onSecondaryBackground20,
      disabledBackgroundColor: colorScheme.onBackground20,
      iconTheme: iconTheme,
      disabledIconTheme: iconTheme.copyWith(color: colorScheme.onBackground70),
      padding: const EdgeInsets.all(12),
    );
  }
}
