import 'package:flutter/cupertino.dart';

import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CliqTheme extends HookWidget {
  final CliqThemeData data;

  final TextDirection? textDirection;

  final Widget child;

  const CliqTheme({
    super.key,
    required this.data,
    required this.child,
    this.textDirection,
  });

  static CliqThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<_InheritedTheme>();
    return theme?.data ?? CliqThemes.standard.light;
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = useBreakpoint();
    return _InheritedTheme(
      data: data,
      child: AnnotatedRegion(
        value: data.colorScheme.systemUiOverlayStyle,
        child: Directionality(
          textDirection:
              textDirection ??
              Directionality.maybeOf(context) ??
              TextDirection.ltr,
          child: DefaultTextStyle(
            style: context.theme.typography.copyM[breakpoint]!.style,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _InheritedTheme extends InheritedWidget {
  final CliqThemeData data;

  const _InheritedTheme({required this.data, required super.child});

  @override
  bool updateShouldNotify(covariant _InheritedTheme old) => data != old.data;
}

extension ThemeBuildContext on BuildContext {
  CliqThemeData get theme => CliqTheme.of(this);
}
