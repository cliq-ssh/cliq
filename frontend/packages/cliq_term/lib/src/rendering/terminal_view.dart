import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:cliq_term/src/utils/selection_helper.dart';
import 'package:cliq_term/src/utils/keyboard_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  late final VoidCallback _focusListener;

  final ScrollController _scrollController = ScrollController();
  bool _userScrolledAwayFromBottom = false;
  bool _isUpdatePending = false;

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
  void didUpdateWidget(TerminalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onUpdate);
      widget.controller.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _focusNode.removeListener(_focusListener);
    if (_shouldDisposeFocusNode) {
      _focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted || _isUpdatePending) return;
    _isUpdatePending = true;

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isUpdatePending = false;
      if (!mounted || !_scrollController.hasClients) return;

      if (!_userScrolledAwayFromBottom) {
        final maxExt = _scrollController.position.maxScrollExtent;
        if (maxExt > 0) {
          _scrollController.jumpTo(maxExt);
        }
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

        // compute char cell size
        final (cellW, cellH) = TerminalPainter.measureChar(
          widget.controller.typography,
        );

        final totalRows = widget.controller.totalRows;

        return Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            if (widget.readOnly) return .ignored;

            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              if (KeyboardHelper.isModifierOnlyKey(event.logicalKey)) {
                return .handled;
              }

              if (widget.pasteShortcut?.isPressed(event) == true) {
                _scrollToBottom();
                widget.controller.clearSelection();
                Clipboard.getData(Clipboard.kTextPlain).then((clip) {
                  String text = clip?.text ?? '';
                  if (text.isNotEmpty) {
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
              widget.controller.clearSelection();
            },
            onPanStart: (details) {
              _focusNode.requestFocus();
              final (absRow, absCol) = _calculateCoords(
                details.localPosition,
                cellW,
                cellH,
              );
              widget.controller.startSelection(absRow, absCol);
            },
            onPanUpdate: (details) {
              final (absRow, absCol) = _calculateCoords(
                details.localPosition,
                cellW,
                cellH,
              );
              widget.controller.updateSelection(absRow, absCol);
            },
            child: Container(
              color: widget.controller.theme.backgroundColor,
              child: ListView.builder(
                scrollCacheExtent: ScrollCacheExtent.pixels(cellH * 10),
                controller: _scrollController,
                itemCount: totalRows,
                itemExtent: cellH,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return TerminalRowWidget(
                    controller: widget.controller,
                    absoluteRowIndex: index,
                    cellWidth: cellW,
                    cellHeight: cellH,
                    readOnly: widget.readOnly,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  (int, int) _calculateCoords(
    Offset localPosition,
    double cellW,
    double cellH,
  ) {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final totalLocalY = localPosition.dy + scrollOffset;

    final absRow = (totalLocalY / cellH).floor();
    final col = (localPosition.dx / cellW).floor();

    return (
      absRow.clamp(0, max(0, widget.controller.totalRows - 1)),
      col.clamp(0, widget.controller.cols - 1),
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

class TerminalRowWidget extends StatelessWidget {
  final TerminalController controller;
  final int absoluteRowIndex;
  final double cellWidth;
  final double cellHeight;
  final bool readOnly;

  const TerminalRowWidget({
    super.key,
    required this.controller,
    required this.absoluteRowIndex,
    required this.cellWidth,
    required this.cellHeight,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final row = controller.activeBuffer.getAbsoluteRow(absoluteRowIndex);

    return Stack(
      children: [
        RepaintBoundary(
          child: CustomPaint(
            size: Size(controller.cols * cellWidth, cellHeight),
            painter: _SingleRowPainter(
              controller: controller,
              absoluteRowIndex: absoluteRowIndex,
              cellWidth: cellWidth,
              cellHeight: cellHeight,
              readOnly: readOnly,
              rowRevision: row.revision,
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: controller.cursorBlinkNotifier,
          builder: (context, isBlinkVisible, child) {
            return CustomPaint(
              size: Size(controller.cols * cellWidth, cellHeight),
              painter: _CursorPainter(
                controller: controller,
                absoluteRowIndex: absoluteRowIndex,
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                readOnly: readOnly,
                isBlinkVisible: isBlinkVisible,
                cursorRow: controller.activeBuffer.cursorRow,
                cursorCol: controller.activeBuffer.cursorCol,
                scrollback: controller.activeBuffer.currentScrollback,
                cursorStyle: controller.cursor.style,
                cursorEnabled: controller.cursor.enabled,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SingleRowPainter extends CustomPainter {
  final TerminalController controller;
  final int absoluteRowIndex;
  final double cellWidth;
  final double cellHeight;
  final bool readOnly;
  final int rowRevision;

  _SingleRowPainter({
    required this.controller,
    required this.absoluteRowIndex,
    required this.cellWidth,
    required this.cellHeight,
    required this.readOnly,
    required this.rowRevision,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final row = controller.activeBuffer.getAbsoluteRow(absoluteRowIndex);
    final cells = row.cells;
    final cols = controller.activeBuffer.cols;
    final rowCols = cells.length;

    // ... rest of paint method

    // 1. Backgrounds
    final bgPaint = Paint();
    Color? lastColor;
    int startCol = 0;

    void flushBg(int endCol) {
      if (lastColor != null) {
        bgPaint.color = lastColor;
        canvas.drawRect(
          Rect.fromLTWH(
            startCol * cellWidth,
            0,
            (endCol - startCol) * cellWidth,
            cellHeight,
          ),
          bgPaint,
        );
      }
    }

    for (int c = 0; c < cols; c++) {
      final cellBg = (c < rowCols) ? cells[c].fmt.bgColor : null;
      if (cellBg != lastColor) {
        flushBg(c);
        lastColor = cellBg;
        startCol = c;
      }
    }
    flushBg(cols);

    // 2. Selection
    if (controller.selection.isSelectionActive) {
      final bounds = SelectionHelper.normalize(
        startRow: controller.selection.startRow!,
        startCol: controller.selection.startCol!,
        endRow: controller.selection.endRow!,
        endCol: controller.selection.endCol!,
        maxRows: controller.totalRows,
        maxCols: cols,
      );

      final rowSel = SelectionHelper.getRowSelection(
        row: absoluteRowIndex,
        bounds: bounds,
        maxCols: cols,
      );

      if (!rowSel.isEmpty) {
        canvas.drawRect(
          Rect.fromLTWH(
            rowSel.start * cellWidth,
            0,
            (rowSel.end - rowSel.start + 1) * cellWidth,
            cellHeight,
          ),
          Paint()..color = controller.theme.selectionColor,
        );
      }
    }

    // 3. Text
    TextPainter? tp = controller.getCachedRow(row);
    if (tp == null) {
      final textStyle = controller.typography.toTextStyle();
      FormattingOptions? lastFmt;
      final List<InlineSpan> spans = [];
      final StringBuffer sb = StringBuffer();

      void flushRun() {
        if (sb.isEmpty) return;
        final fmt = lastFmt ?? FormattingOptions.defaultFormat;
        final effectiveFg = fmt.concealed
            ? controller.theme.foregroundColor.withAlpha(0)
            : (fmt.effectiveFgColor ?? controller.theme.foregroundColor);

        final style = textStyle.copyWith(
          color: effectiveFg,
          fontWeight: fmt.bold ? FontWeight.w700 : null,
          fontStyle: fmt.italic ? FontStyle.italic : FontStyle.normal,
          decoration: fmt.underline == Underline.none
              ? TextDecoration.none
              : TextDecoration.underline,
          decorationStyle: fmt.underline == Underline.double
              ? TextDecorationStyle.double
              : TextDecorationStyle.solid,
        );
        spans.add(TextSpan(text: sb.toString(), style: style));
        sb.clear();
      }

      for (int c = 0; c < cols; c++) {
        final cell = (c < rowCols) ? cells[c] : null;
        final fmt = cell?.fmt ?? FormattingOptions.defaultFormat;
        if (lastFmt == null) {
          lastFmt = fmt;
        } else if (!identical(lastFmt, fmt) && lastFmt != fmt) {
          flushRun();
          lastFmt = fmt;
        }
        sb.write(cell?.ch ?? ' ');
      }
      flushRun();

      if (spans.isNotEmpty) {
        tp = TextPainter(
          text: TextSpan(children: spans),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(minWidth: 0, maxWidth: cols * cellWidth);
        controller.cacheRow(row, tp);
      }
    }

    if (tp != null) {
      tp.paint(canvas, Offset.zero);
    }
  }

  @override
  bool shouldRepaint(covariant _SingleRowPainter oldDelegate) {
    final bool basicChanged =
        oldDelegate.controller != controller ||
        oldDelegate.absoluteRowIndex != absoluteRowIndex ||
        oldDelegate.readOnly != readOnly ||
        oldDelegate.rowRevision != rowRevision;

    if (basicChanged) return true;

    // Repaint if selection state changed and this row is involved
    if (controller.selection.active) {
      final start = controller.selection.startRow ?? 0;
      final end = controller.selection.endRow ?? 0;
      final minR = min(start, end);
      final maxR = max(start, end);
      if (absoluteRowIndex >= minR && absoluteRowIndex <= maxR) {
        return true;
      }
    }

    // If selection WAS active and now it's not, we might need to repaint
    if (oldDelegate.controller.selection.active !=
        controller.selection.active) {
      final start = oldDelegate.controller.selection.startRow ?? 0;
      final end = oldDelegate.controller.selection.endRow ?? 0;
      final minR = min(start, end);
      final maxR = max(start, end);
      if (absoluteRowIndex >= minR && absoluteRowIndex <= maxR) {
        return true;
      }
    }

    return false;
  }
}

class _CursorPainter extends CustomPainter {
  final TerminalController controller;
  final int absoluteRowIndex;
  final double cellWidth;
  final double cellHeight;
  final bool readOnly;
  final bool isBlinkVisible;
  final int cursorRow;
  final int cursorCol;
  final int scrollback;
  final CursorStyle cursorStyle;
  final bool cursorEnabled;

  _CursorPainter({
    required this.controller,
    required this.absoluteRowIndex,
    required this.cellWidth,
    required this.cellHeight,
    required this.readOnly,
    required this.isBlinkVisible,
    required this.cursorRow,
    required this.cursorCol,
    required this.scrollback,
    required this.cursorStyle,
    required this.cursorEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (readOnly || !isBlinkVisible || !cursorEnabled) {
      return;
    }

    final absCursorRow = scrollback + cursorRow;

    if (absCursorRow != absoluteRowIndex) {
      return;
    }

    final cols = controller.activeBuffer.cols;

    if (cursorCol >= 0 && cursorCol < cols) {
      final cell = controller.activeBuffer.getAbsoluteCell(
        absCursorRow,
        cursorCol,
      );
      final cellFg = cell.fmt.effectiveFgColor;
      final cellBg = cell.fmt.effectiveBgColor;

      final Color fillColor = cellFg ?? controller.theme.foregroundColor;
      final Color charColor = cellBg ?? controller.theme.backgroundColor;

      final cursorRect = Rect.fromLTWH(
        cursorCol * cellWidth,
        0,
        cellWidth,
        cellHeight,
      );

      switch (cursorStyle) {
        case CursorStyle.block:
          canvas.drawRect(cursorRect, Paint()..color = fillColor);
          final displayedChar = cell.ch.isEmpty ? ' ' : cell.ch;
          final charStyle = TextStyle(
            color: charColor,
            fontSize: controller.typography.fontSize.toDouble(),
            fontFamily: controller.typography.fontFamily,
            fontWeight: cell.fmt.bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: cell.fmt.italic ? FontStyle.italic : FontStyle.normal,
          );
          TextPainter(
              text: TextSpan(text: displayedChar, style: charStyle),
              textDirection: TextDirection.ltr,
            )
            ..layout(minWidth: 0, maxWidth: cellWidth)
            ..paint(canvas, Offset(cursorCol * cellWidth, 0));
          break;
        case CursorStyle.underline:
          final underlineHeight = cellHeight * 0.18;
          canvas.drawRect(
            Rect.fromLTWH(
              cursorCol * cellWidth,
              cellHeight - underlineHeight,
              cellWidth,
              underlineHeight,
            ),
            Paint()..color = fillColor,
          );
          break;
        case CursorStyle.bar:
          final barWidth = max(1.0, cellWidth * 0.12);
          canvas.drawRect(
            Rect.fromLTWH(cursorCol * cellWidth, 0, barWidth, cellHeight),
            Paint()..color = fillColor,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CursorPainter oldDelegate) {
    return oldDelegate.isBlinkVisible != isBlinkVisible ||
        oldDelegate.cursorRow != cursorRow ||
        oldDelegate.cursorCol != cursorCol ||
        oldDelegate.scrollback != scrollback ||
        oldDelegate.cursorStyle != cursorStyle ||
        oldDelegate.cursorEnabled != cursorEnabled ||
        oldDelegate.controller != controller ||
        oldDelegate.absoluteRowIndex != absoluteRowIndex ||
        oldDelegate.readOnly != readOnly;
  }
}
