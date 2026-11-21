import '../../../cliq_grid.dart';

import 'package:material_ui/material_ui.dart';

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
        final breakpoint = CliqTheme.of(context).breakpoints.getBreakpoint(
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
