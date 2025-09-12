import 'package:flutter/cupertino.dart';

import 'package:cliq_ui/cliq_ui.dart';

/// An implementation of the bootstrap grid row in flutter.
/// Inspired by the flutter_bootstrap package.
class CliqGridRow extends StatelessWidget {
  final List<CliqGridColumn> children;
  final double? height;
  final BoxDecoration? decoration;
  final WrapAlignment alignment;

  const CliqGridRow({
    super.key,
    required this.children,
    this.decoration,
    this.height,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: height ?? 0.0,
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          decoration: decoration,
          child: Wrap(
            alignment: alignment,
            direction: Axis.horizontal,
            children: children,
          ),
        );
      },
    );
  }
}
