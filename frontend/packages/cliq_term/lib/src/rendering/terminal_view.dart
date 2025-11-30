import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:flutter/material.dart';

class TerminalView extends StatefulWidget {
  final TerminalController controller;
  final double fontSize;
  final Color defaultFg;
  final Color defaultBg;

  const TerminalView({
    super.key,
    required this.controller,
    this.fontSize = 14,
    this.defaultFg = Colors.white,
    this.defaultBg = Colors.black,
  });

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  // TODO: replace this
  static const double temporaryFontSize = 16.0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _focusNode.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final (cellW, cellH) = TerminalPainter.measureChar(temporaryFontSize);
        final newCols = max(1, (constraints.maxWidth / cellW).floor());
        final newRows = max(1, (constraints.maxHeight / cellH).floor());

        // inform controller if size changed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.controller.cols != newCols ||
              widget.controller.rows != newRows) {
            widget.controller.resize(newRows, newCols);
          }
        });

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (ev) => widget.controller.handleKey(ev),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // TODO: implement text selection
            onTap: () => _focusNode.requestFocus(),
            child: CustomPaint(
              size: Size.infinite,
              painter: TerminalPainter(
                widget.controller,
                temporaryFontSize,
                widget.defaultFg,
                widget.defaultBg,
              ),
            ),
          ),
        );
      },
    );
  }
}
