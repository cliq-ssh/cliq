import 'dart:math';

import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';

/// An implementation of the bootstrap grid col in flutter.
/// Inspired by the flutter_bootstrap package.
class CliqGridColumn extends StatelessWidget {
  final Widget child;
  final FlexFit fit;
  late final BreakpointMap<int> sizes;
  final List<Breakpoint> invisible;
  final bool absoluteSizes;
  final CliqGridColumnStyle? style;

  CliqGridColumn({
    super.key,
    required this.child,
    this.fit = FlexFit.loose,
    this.absoluteSizes = true,
    BreakpointMap<int> sizes = const {},
    this.invisible = const [],
    this.style,
  }) : sizes = sizes.cascadeUp(defaultValue: 12);

  @override
  Widget build(BuildContext context) {
    final grid = context.theme.grid;
    final style = this.style ?? context.theme.gridColumnStyle;

    return ColoredBox(
      color: style.debugColor,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final breakpoint = context.theme.breakpoints.getBreakpoint(
            absoluteSizes
                ? MediaQuery.of(context).size.width
                : constraints.maxWidth,
          );

          return CliqGridVisible(
            invisible: invisible,
            child: SizedBox(
              width:
                  sizes[breakpoint]! *
                  constraints.maxWidth *
                  grid.oneColumnRatio,
              child: Padding(
                padding: grid.gutterSize == 0.0
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(horizontal: grid.gutterSize / 2),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

final class CliqGridColumnStyle {
  final Color debugColor;

  const CliqGridColumnStyle({required this.debugColor});

  factory CliqGridColumnStyle.inherit({required bool debug}) {
    // get a random color from the theme if debug is true
    return CliqGridColumnStyle(
      debugColor: debug
          ? Color(
              (Random().nextDouble() * 0xFFFFFF).toInt(),
            ).withValues(alpha: 1)
          : Colors.transparent,
    );
  }
}
