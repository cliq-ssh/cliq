import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalView extends StatefulWidget {
  final TerminalController controller;
  final FocusNode? focusNode;

  const TerminalView({super.key, required this.controller, this.focusNode});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.controller.startCursorBlink();
      } else {
        widget.controller.stopCursorBlink();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _focusNode.removeListener(() {});
    _focusNode.dispose();
    widget.controller.stopCursorBlink();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final (cellW, cellH) = TerminalPainter.measureChar(
          widget.controller.typography,
        );
        final newCols = max(1, (constraints.maxWidth / cellW).floor());
        final newRows = max(1, (constraints.maxHeight / cellH).floor());

        // inform controller if size changed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.controller.cols != newCols ||
              widget.controller.rows != newRows) {
            widget.controller.resize(newRows, newCols);
          }
        });

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              // handle tab locally so focus doesn't move to other widgets
              if (event.logicalKey == LogicalKeyboardKey.tab) {
                widget.controller.handleKey(event);
                return .handled;
              }
              widget.controller.handleKey(event);
              return .handled;
            }
            return .ignored;
          },

          // TODO: focus when selecting tab
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // TODO: implement text selection
            onTap: () => _focusNode.requestFocus(),
            child: CustomPaint(
              size: Size.infinite,
              painter: TerminalPainter(widget.controller),
            ),
          ),
        );
      },
    );
  }
}
