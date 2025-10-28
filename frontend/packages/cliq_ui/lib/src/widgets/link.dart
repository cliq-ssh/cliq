import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CliqLink extends HookWidget {
  final TextSpan label;
  final Widget? icon;
  final Function()? onPressed;
  final bool reverseOrder;
  final bool disabled;
  final CliqLinkStyle? style;

  const CliqLink({
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
    final style = this.style ?? context.theme.linkStyle;
    final textStyle = context.theme.typography;
    final states = useState<Set<WidgetState>>({});
    final breakpoint = useBreakpoint();

    useEffect(() {
      Set<WidgetState> newStates = <WidgetState>{};
      if (disabled || onPressed == null) newStates = {WidgetState.disabled};
      states.value = newStates;

      return null;
    }, [disabled]);

    return CliqInteractable.fromDefaultWidgetStates(
      states.value,
      onTap: WidgetStateProperty.fromMap({
        WidgetState.disabled: null,
        WidgetState.any: onPressed,
      }).resolve(states.value),
      child: Text.rich(
        style: textStyle.copyS[breakpoint]!.style.copyWith(
          color: style.iconTheme.resolve(states.value).color
        ),
        TextSpan(
          children: [
            if (icon != null)
              WidgetSpan(
                child: IconTheme(
                  data: style.iconTheme.resolve(states.value),
                  child: icon!,
                ),
              ),
            if (icon != null) const WidgetSpan(child: SizedBox(width: 8)),
            label,
          ]
        )
      ),
    );
  }
}

final class CliqLinkStyle {
  final WidgetStateProperty<IconThemeData> iconTheme;

  const CliqLinkStyle({
    required this.iconTheme,
  });

  factory CliqLinkStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    final iconTheme = IconThemeData(color: colorScheme.primary, size: 20);
    return CliqLinkStyle(
      iconTheme: WidgetStateProperty.fromMap({
        WidgetState.disabled: iconTheme.copyWith(
          color: colorScheme.onBackground20,
        ),
        WidgetState.any: iconTheme,
      }),
    );
  }
}
