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
          child: StatefulBuilder(
            builder: (_, _) {
              final List<Widget> items = [
                IconTheme(
                  data: style.iconTheme.resolve(states.value),
                  child: icon,
                ),
                if (label != null)
                  Flexible(
                    child: CliqDefaultTypography(
                      size: textStyle.copyS,
                      color: style.iconTheme.resolve(states.value).color,
                      fontFamily: CliqFontFamily.secondary,
                      child: label!,
                    ),
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
  final WidgetStateColor backgroundColor;
  final WidgetStateProperty<IconThemeData> iconTheme;
  final EdgeInsetsGeometry padding;

  const CliqIconButtonStyle({
    required this.backgroundColor,
    required this.iconTheme,
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
      backgroundColor: WidgetStateColor.fromMap({
        WidgetState.hovered: colorScheme.onSecondaryBackground10,
        WidgetState.disabled: colorScheme.onBackground20,
        WidgetState.any: colorScheme.secondaryBackground50,
      }),
      iconTheme: WidgetStateProperty.fromMap({
        WidgetState.disabled: iconTheme.copyWith(
          color: colorScheme.onBackground70,
        ),
        WidgetState.any: iconTheme,
      }),
      padding: const EdgeInsets.all(12),
    );
  }
}
