import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart' show FScaffold;

class ResponsiveSheet extends StatelessWidget {
  static const double maxDesktopRatio = 9 / 16;

  final Widget child;

  const new({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLg = context.theme.breakpoints.getBreakpoint(size.width) >= .lg;

    final dialog = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          if (isLg) {
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
    );

    if (isLg) {
      return dialog;
    }

    return FScaffold(
      childPad: false,
      resizeToAvoidBottomInset: false,
      child: dialog,
    );
  }
}
