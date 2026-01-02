import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

final class Commons {
  const Commons();

  static Future<T?> showResponsiveDialog<T>(
    BuildContext context,
    Breakpoint currentBreakpoint,
    Widget Function(BuildContext) builder,
  ) {
    if (currentBreakpoint.index >= Breakpoint.md.index) {
      return showFSheet(context: context, side: FLayout.rtl, builder: builder);
    }

    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: builder, fullscreenDialog: true));
  }
}
