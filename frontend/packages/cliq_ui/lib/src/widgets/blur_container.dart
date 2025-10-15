import 'dart:ui';

import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

class CliqBlurContainer extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final Color? outlineColor;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final CliqBlurContainerStyle? style;

  const CliqBlurContainer({
    super.key,
    this.child,
    this.color,
    this.outlineColor,
    this.borderRadius,
    this.padding,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.blurContainerStyle;

    return ClipRRect(
      borderRadius: borderRadius ?? style.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: style.blur, sigmaY: style.blur),
        child: AnimatedContainer(
          duration: style.animationDuration,
          decoration: BoxDecoration(
            color: color ?? style.color,
            borderRadius: borderRadius ?? style.borderRadius,
            border: Border.all(
              color: outlineColor ?? style.outlineColor,
              width: 1,
            ),
          ),
          child: Container(padding: padding, child: child),
        ),
      ),
    );
  }
}

final class CliqBlurContainerStyle {
  final Color color;
  final Color outlineColor;
  final double blur;
  final BorderRadiusGeometry borderRadius;
  final Duration animationDuration;

  const CliqBlurContainerStyle({
    required this.color,
    required this.outlineColor,
    required this.blur,
    required this.borderRadius,
    required this.animationDuration,
  });

  factory CliqBlurContainerStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqBlurContainerStyle(
      color: colorScheme.secondaryBackground50,
      outlineColor: colorScheme.secondaryBackground,
      blur: 7.0,
      borderRadius: BorderRadius.circular(25),
      animationDuration: style.animationDuration,
    );
  }
}
