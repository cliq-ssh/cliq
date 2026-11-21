import 'package:cupertino_ui/cupertino_ui.dart';

import '../../cliq_grid.dart';

import 'package:material_ui/material_ui.dart';
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
    return theme?.data ?? .inherit();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTheme(
      data: data,
      child: Directionality(
        textDirection:
            textDirection ??
            Directionality.maybeOf(context) ??
            TextDirection.ltr,
        child: child,
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
