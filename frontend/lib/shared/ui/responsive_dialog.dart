import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart' show FScaffold;

class ResponsiveDialog extends StatelessWidget {
  static const double maxDesktopRatio = 9 / 16;

  final Widget child;

  const ResponsiveDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;

            if (context.theme.breakpoints.getBreakpoint(size.width) >= .lg) {
              final dialogWidth = size.width * maxDesktopRatio;
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: size.height,
                ),
                child: child,
              );
            }

            return child;
          },
        ),
      ),
    );
  }
}
