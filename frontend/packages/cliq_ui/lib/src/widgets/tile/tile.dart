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
      child: CliqBlurContainer(
        color: style.backgroundColor.resolve(states.value),
        outlineColor: style.outlineColor ?? CliqColorScheme.calculateOutlineColor(style.backgroundColor.resolve(states.value)),
        padding: style.padding,
        borderRadius: style.borderRadius,
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
                      color: style.iconTheme.resolve(states.value).color,
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
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? outlineColor;

  const CliqTileStyle({
    required this.backgroundColor,
    required this.iconTheme,
    required this.borderRadius,
    required this.padding,
    this.outlineColor,
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
      borderRadius: BorderRadius.circular(25),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  CliqTileStyle copyWith({
    WidgetStateColor? backgroundColor,
    WidgetStateProperty<IconThemeData>? iconTheme,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? outlineColor,
  }) {
    return CliqTileStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconTheme: iconTheme ?? this.iconTheme,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      outlineColor: outlineColor ?? this.outlineColor,
    );
  }
}
