import 'package:cliq_grid/cliq_grid.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:forui/forui.dart' show FScaffold;

class ResponsiveSheet extends StatelessWidget {
  static const double maxDesktopRatio = 9 / 16;

  final Widget child;

  const new({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLg =
        CliqTheme.of(context).breakpoints.getBreakpoint(size.width) >= .lg;

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
