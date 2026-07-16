import 'dart:math';

import 'package:flutter/material.dart';

import '../../cliq_term.dart';
import '../utils/selection_helper.dart';

class SingleRowPainter extends CustomPainter {
  final TerminalController controller;
  final int absoluteRowIndex;
  final double cellWidth;
  final double cellHeight;
  final bool readOnly;
  final int rowRevision;
  final TerminalBufferRow row;

  SingleRowPainter({
    required this.controller,
    required this.absoluteRowIndex,
    required this.cellWidth,
    required this.cellHeight,
    required this.readOnly,
    required this.rowRevision,
    required this.row,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final row = controller.activeBuffer.getAbsoluteRow(absoluteRowIndex);
    final cells = row.cells;
    final cols = controller.activeBuffer.cols;
    final rowCols = cells.length;

    final bgPaint = Paint();
    Color? lastColor;
    int startCol = 0;

    void flushBg(int endCol) {
      if (lastColor != null) {
        bgPaint.color = lastColor;
        canvas.drawRect(
          .fromLTWH(
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
      Color? cellBg;
      if (c < rowCols) {
        final fmt = cells[c].fmt;
        cellBg = fmt.inverted
            ? (fmt.fgColor ?? controller.theme.foregroundColor)
            : fmt.bgColor;
      }
      if (cellBg != lastColor) {
        flushBg(c);
        lastColor = cellBg;
        startCol = c;
      }
    }
    flushBg(cols);

    // Draw selection overlay if active (selection coordinates are in absolute rows)
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
    final textStyle = controller.typography.toTextStyle();
    for (int c = 0; c < cols; c++) {
      final cell = (c < rowCols) ? cells[c] : null;
      final ch = cell?.ch ?? ' ';
      if (ch.isEmpty || ch == ' ') continue;

      final fmt = cell?.fmt ?? FormattingOptions.defaultFormat;

      final effectiveFg = fmt.concealed
          ? controller.theme.foregroundColor.withAlpha(0)
          : (fmt.inverted
                ? (fmt.bgColor ?? controller.theme.backgroundColor)
                : (fmt.fgColor ?? controller.theme.foregroundColor));

      final codepoint = ch.length == 1 ? ch.codeUnitAt(0) : -1;
      final isBraille = CharWidth.isBraillePattern(codepoint);

      // only clip if the character is outside the printable ASCII range (0x20 to 0x7E)
      final needsClip = codepoint < 0x20 || codepoint > 0x7E;

      final cacheKey =
          '$ch|${effectiveFg.toARGB32()}|${fmt.bold}|${fmt.italic}|${fmt.underline}|$isBraille';

      TextPainter? glyph = controller.getCachedGlyph(cacheKey);
      if (glyph == null) {
        final style = textStyle.copyWith(
          color: effectiveFg,
          fontFamily: isBraille ? 'Noto Sans Symbols2' : null,
          fontWeight: fmt.bold ? FontWeight.w700 : null,
          fontStyle: fmt.italic ? FontStyle.italic : FontStyle.normal,
          decoration: fmt.underline == Underline.none
              ? TextDecoration.none
              : TextDecoration.underline,
          decorationStyle: fmt.underline == Underline.double
              ? TextDecorationStyle.double
              : TextDecorationStyle.solid,
        );

        glyph = TextPainter(
          text: TextSpan(text: ch, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: cellWidth);

        controller.cacheGlyph(cacheKey, glyph);
      }

      final dx = c * cellWidth + (cellWidth - glyph.width) / 2;

      if (needsClip) {
        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(c * cellWidth, 0, cellWidth, cellHeight),
          doAntiAlias: false,
        );
        glyph.paint(canvas, Offset(dx, 0));
        canvas.restore();
      } else {
        glyph.paint(canvas, Offset(dx, 0));
      }
    }
  }

  @override
  bool shouldRepaint(covariant SingleRowPainter oldDelegate) {
    final bool basicChanged =
        oldDelegate.controller != controller ||
        oldDelegate.absoluteRowIndex != absoluteRowIndex ||
        oldDelegate.readOnly != readOnly ||
        !identical(oldDelegate.row, row) ||
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

class CursorPainter extends CustomPainter {
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

  CursorPainter({
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
    if (readOnly ||
        !isBlinkVisible ||
        !cursorEnabled ||
        !controller.cursorVisible) {
      return;
    }

    final absCursorRow = scrollback + cursorRow;

    if (absCursorRow != absoluteRowIndex) {
      return;
    }

    final cols = controller.activeBuffer.cols;
    if (cursorCol < 0 || cursorCol >= cols) return;

    final cell = controller.activeBuffer.getAbsoluteCell(
      absCursorRow,
      cursorCol,
    );

    final Color fillColor = cell.fmt.inverted
        ? (cell.fmt.bgColor ?? controller.theme.backgroundColor)
        : (cell.fmt.fgColor ?? controller.theme.foregroundColor);
    final Color charColor = cell.fmt.inverted
        ? (cell.fmt.fgColor ?? controller.theme.foregroundColor)
        : (cell.fmt.bgColor ?? controller.theme.backgroundColor);

    final cursorRect = Rect.fromLTWH(
      cursorCol * cellWidth,
      0,
      cellWidth,
      cellHeight,
    );

    switch (cursorStyle) {
      case .block:
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
      case .underline:
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
      case .bar:
        final barWidth = max(1.0, cellWidth * 0.12);
        canvas.drawRect(
          Rect.fromLTWH(cursorCol * cellWidth, 0, barWidth, cellHeight),
          Paint()..color = fillColor,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CursorPainter oldDelegate) {
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
