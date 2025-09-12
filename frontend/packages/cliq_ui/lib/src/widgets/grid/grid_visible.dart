import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';

class CliqGridVisible extends StatelessWidget {
  final Widget child;
  final List<Breakpoint> invisible;
  final bool absoluteSizes;

  const CliqGridVisible({
    super.key,
    required this.child,
    this.invisible = const [],
    this.absoluteSizes = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final breakpoint = context.theme.breakpoints.getBreakpoint(
          absoluteSizes
              ? MediaQuery.of(context).size.width
              : constraints.maxWidth,
        );

        if (invisible.contains(breakpoint)) {
          return SizedBox.shrink();
        }

        return child;
      },
    );
  }
}
