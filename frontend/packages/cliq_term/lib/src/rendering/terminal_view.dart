import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/terminal_input.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:cliq_term/src/utils/gesture_selection_handler.dart';
import 'package:cliq_term/src/utils/keyboard_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalView extends StatefulWidget {
  final TerminalController controller;
  final FocusNode? focusNode;
  final bool readOnly;

  final KeyboardShortcut? copyShortcut;
  final KeyboardShortcut? pasteShortcut;

  const TerminalView({
    super.key,
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.copyShortcut,
    this.pasteShortcut,
  });

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  late final FocusNode _focusNode;
  late final bool _shouldDisposeFocusNode;

  final ScrollController _scrollController = ScrollController();
  bool _userScrolledAwayFromBottom = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _shouldDisposeFocusNode = widget.focusNode == null;

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
    if (_shouldDisposeFocusNode) {
      _focusNode.dispose();
    }
    _scrollController.dispose();
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

  void _scrollToBottom() {
    _userScrolledAwayFromBottom = false;
    if (!_scrollController.hasClients) return;
    final maxExt = _scrollController.position.maxScrollExtent;
    if (maxExt > 0) {
      _scrollController.jumpTo(maxExt);
    }
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

        return TerminalInput(
          focusNode: _focusNode,
          onInput: (text) {
            _scrollToBottom();
            widget.controller.clearSelection();
            widget.controller.onInput?.call(text);
          },
          onKeyEvent: (node, event) {
            if (widget.readOnly) {
              return .ignored;
            }

            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              // Do not clear selection on modifier-only key presses.
              if (KeyboardHelper.isModifierOnlyKey(event.logicalKey)) {
                return .handled;
              }

              if (widget.pasteShortcut?.isPressed(event) == true) {
                _scrollToBottom();
                widget.controller.clearSelection();
                Clipboard.getData(Clipboard.kTextPlain).then((clip) {
                  String text = clip?.text ?? '';
                  if (text.isNotEmpty) {
                    // Strip trailing newlines to prevent auto-execution on multiline paste
                    text = _stripTrailingNewlines(text);
                    widget.controller.onInput?.call(text);
                  }
                });
                return .handled;
              }

              if (widget.copyShortcut?.isPressed(event) == true) {
                final selection = widget.controller.getSelectedText();
                if (selection?.isNotEmpty == true) {
                  Clipboard.setData(ClipboardData(text: selection!));
                }
                return .handled;
              }

              _scrollToBottom();
              widget.controller.clearSelection();
              widget.controller.handleKey(event);
              return .handled;
            }
            return .ignored;
          },

          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _focusNode.requestFocus();
              // clear any existing selection on simple click
              widget.controller.clearSelection();
            },
            onPanStart: (details) {
              _focusNode.requestFocus();
              final (
                absRow,
                absCol,
              ) = GestureSelectionHandler.calculateAbsoluteCoordinates(
                localPosition: details.localPosition,
                scrollOffset: _scrollController.offset,
                cellWidth: cellW,
                cellHeight: cellH,
                totalRows: widget.controller.totalRows,
                maxCols: widget.controller.cols,
              );
              widget.controller.startSelection(absRow, absCol);
            },
            onPanUpdate: (details) {
              final (
                absRow,
                absCol,
              ) = GestureSelectionHandler.calculateAbsoluteCoordinates(
                localPosition: details.localPosition,
                scrollOffset: _scrollController.offset,
                cellWidth: cellW,
                cellHeight: cellH,
                totalRows: widget.controller.totalRows,
                maxCols: widget.controller.cols,
              );
              widget.controller.updateSelection(absRow, absCol);
            },
            onPanEnd: (details) {
              // selection remains active until user clears or starts another selection
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight < constraints.maxHeight
                    ? constraints.maxHeight
                    : canvasHeight,
                child: CustomPaint(
                  painter: TerminalPainter(
                    widget.controller,
                    readOnly: widget.readOnly,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Strip trailing newlines from multiline text to prevent auto-execution.
  /// Returns trimmed text if multiline, otherwise returns original text.
  ///
  /// TODO: There is a escape code that prevents auto-execution of pasted commands, but it is not implemented atm.
  static String _stripTrailingNewlines(String text) {
    if (text.contains('\n') && text.endsWith('\n')) {
      return text.trimRight();
    }
    return text;
  }
}
