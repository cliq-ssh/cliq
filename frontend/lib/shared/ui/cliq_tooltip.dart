import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:forui/forui.dart';

/// Wrapper for the [FTooltip] widget which always sets the [overlayLocation] to
/// [OverlayLocation.rootOverlay] by default.
class const CliqTooltip({
  super.key,
  required final Widget text,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (_, _) => text,
      style: .delta(
        decoration: .boxDelta(
          color: context.theme.colors.background,
          border: .all(color: context.theme.colors.border, width: 1),
        ),
        textStyle: .delta(color: context.theme.colors.foreground),
      ),
      overlayLocation: .rootOverlay,
      child: child,
    );
  }
}
