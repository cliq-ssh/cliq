import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

final class CliqStyle {
  final BorderRadius borderRadius;
  final double borderWidth;
  final double verticalPagePadding;
  final Duration animationDuration;

  const CliqStyle({
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.borderWidth = 1,
    this.verticalPagePadding = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  CliqStyle.inherit({
    required CliqColorScheme colorScheme,
    required CliqTypographyData typography,
  }) : this();
}
