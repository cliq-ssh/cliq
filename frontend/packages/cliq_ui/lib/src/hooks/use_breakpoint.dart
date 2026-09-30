import 'package:cliq_ui/cliq_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Breakpoint useBreakpoint() {
  final context = useContext();
  final width = MediaQuery.of(context).size.width;

  return useMemoized(() => context.theme.breakpoints.getBreakpoint(width), [
    width,
  ]);
}
