import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CliqTile extends HookWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onPressed;
  final bool disabled;
  final CliqTileStyle? style;

  const CliqTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.disabled = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.tileStyle;
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
        padding: style.padding,
        child: Row(
          spacing: 16,
          children: [
            if (leading != null)
              IconTheme(
                data: style.iconTheme.resolve(states.value),
                child: leading!,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    CliqDefaultTypography(
                      size: context.theme.typography.copyS,
                      child: title!,
                    ),
                  if (subtitle != null)
                    CliqDefaultTypography(
                      size: context.theme.typography.copyS,
                      color: context.theme.colorScheme.onBackground70,
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            if (trailing != null)
              IconTheme(
                data: style.iconTheme.resolve(states.value),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

final class CliqTileStyle {
  final WidgetStateColor backgroundColor;
  final WidgetStateProperty<IconThemeData> iconTheme;
  final EdgeInsetsGeometry padding;

  const CliqTileStyle({
    required this.backgroundColor,
    required this.iconTheme,
    required this.padding,
  });

  factory CliqTileStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    final iconTheme = IconThemeData(
      color: colorScheme.onSecondaryBackground,
      size: 20,
    );
    return CliqTileStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
