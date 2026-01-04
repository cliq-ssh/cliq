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
  late final FocusNode _focusNode;
  late final bool _shouldDisposeFocusNode;
  late final VoidCallback _focusListener;

  final ScrollController _scrollController = ScrollController();
  bool _userScrolledAwayFromBottom = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _shouldDisposeFocusNode = widget.focusNode == null;

    _focusListener = () {
      if (_focusNode.hasFocus) {
        widget.controller.startCursorBlink();
      } else {
        widget.controller.stopCursorBlink();
      }
    };
    _focusNode.addListener(_focusListener);

    widget.controller.addListener(_onUpdate);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxExt = _scrollController.position.maxScrollExtent;
      final atBottom = _scrollController.offset >= (maxExt - 20);
      _userScrolledAwayFromBottom = !atBottom;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _focusNode.removeListener(_focusListener);
    if (_shouldDisposeFocusNode) {
      _focusNode.dispose();
    }
    _scrollController.dispose();
    widget.controller.stopCursorBlink();
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (_userScrolledAwayFromBottom) {
        return; // user is viewing history; don't yank them
      }
      // jump to bottom
      final maxExt = _scrollController.position.maxScrollExtent;
      if (maxExt > 0) {
        _scrollController.jumpTo(maxExt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // inform controller if size changed
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.controller.fitResize(constraints.biggest),
        );

        // compute char cell size to compute overall canvas size
        final (cellW, cellH) = TerminalPainter.measureChar(
          widget.controller.typography,
        );

        // total rows available in front buffer (visible + scrollback)
        final totalRows = widget.controller.totalRows;
        final totalCols = widget.controller.cols;

        final canvasWidth = (totalCols > 0)
            ? totalCols * cellW
            : constraints.maxWidth;
        final canvasHeight = (totalRows > 0)
            ? totalRows * cellH
            : constraints.maxHeight;

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
            behavior: HitTestBehavior.translucent,
            // TODO: implement text selection
            onTap: () => _focusNode.requestFocus(),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight < constraints.maxHeight
                    ? constraints.maxHeight
                    : canvasHeight,
                child: CustomPaint(painter: TerminalPainter(widget.controller)),
              ),
            ),
          ),
        );
      },
    );
  }
}
