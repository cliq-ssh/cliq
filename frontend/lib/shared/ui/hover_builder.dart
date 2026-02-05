import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HoverBuilder<T> extends StatefulWidget {
  final Widget Function(BuildContext, bool) builder;
  final Widget Function(Widget)? wrapper;

  const HoverBuilder({super.key, required this.builder, this.wrapper});

  @override
  State<HoverBuilder<T>> createState() => _HoverBuilderState<T>();
}

class _HoverBuilderState<T> extends State<HoverBuilder<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget child = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );

    if (widget.wrapper != null) {
      child = widget.wrapper!(child);
    }

    return child;
  }
}
