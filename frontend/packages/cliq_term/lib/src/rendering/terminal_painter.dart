import 'dart:math';

import 'package:flutter/material.dart';

import '../../cliq_term.dart';
import '../utils/selection_helper.dart';

class TerminalPainter extends CustomPainter {
  final TerminalController controller;
  final bool readOnly;

  const TerminalPainter(this.controller, {this.readOnly = false})
    : super(repaint: controller);

  static final Map<TerminalTypography, (double, double)> _measureCache = {};

  /// Calculates the width and height of a single character cell based on the provided typography.
  static (double width, double height) measureChar(
    TerminalTypography typography,
  ) {
    if (_measureCache.containsKey(typography)) {
      return _measureCache[typography]!;
    }
    final probe = TextPainter(
      text: TextSpan(text: 'MMMM', style: typography.toTextStyle()),
      textDirection: TextDirection.ltr,
    )..layout();
    final res = (probe.width / 4, probe.height);
    _measureCache[typography] = res;
    return res;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final clip = canvas.getLocalClipBounds();
    if (clip.isEmpty) return;

    // set background
    final bgPaint = Paint()..color = controller.theme.backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final (cellW, cellH) = measureChar(controller.typography);

    // total rows available in the buffer (visible rows + scrollback (if any))
    final totalRows = controller.activeBuffer.length;
    final cols = controller.activeBuffer.cols;

    if (totalRows == 0 || cols == 0) return;

    final firstRow = (clip.top / cellH).floor().clamp(0, totalRows - 1);
    final lastRow = (clip.bottom / cellH).ceil().clamp(0, totalRows - 1);

    // draw cell backgrounds for every buffer row
    final cellBgPaint = Paint();
    for (int r = firstRow; r <= lastRow; r++) {
      final row = controller.activeBuffer.getAbsoluteRow(r);
      final cells = row.cells;
      final rowCols = cells.length;
      Color? lastColor;
      int startCol = 0;

      void flushBg(int endCol) {
        if (lastColor != null) {
          cellBgPaint.color = lastColor;
          canvas.drawRect(
            Rect.fromLTWH(
              startCol * cellW,
              r * cellH,
              (endCol - startCol) * cellW,
              cellH,
            ),
            cellBgPaint,
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
    }

    // Draw selection overlay if active (selection coordinates are in visible rows)
    if (controller.selection.isSelectionActive) {
      // normalize selection using helper
      final bounds = SelectionHelper.normalize(
        startRow: controller.selection.startRow!,
        startCol: controller.selection.startCol!,
        endRow: controller.selection.endRow!,
        endCol: controller.selection.endCol!,
        maxRows: controller.rows,
        maxCols: cols,
      );

      // render selection overlay for each row
      for (var vr = bounds.startRow; vr <= bounds.endRow; vr++) {
        final absRow = controller.activeBuffer.currentScrollback + vr;
        if (absRow < firstRow || absRow > lastRow) continue;

        final rowSel = SelectionHelper.getRowSelection(
          row: vr,
          bounds: bounds,
          maxCols: cols,
        );

        if (!rowSel.isEmpty) {
          final rect = Rect.fromLTWH(
            rowSel.start * cellW,
            absRow * cellH,
            (rowSel.end - rowSel.start + 1) * cellW,
            cellH,
          );
          canvas.drawRect(
            rect,
            Paint()..color = controller.theme.selectionColor,
          );
        }
      }
    }

    // paint text for each buffer row
    final textStyle = controller.typography.toTextStyle();
    for (int r = firstRow; r <= lastRow; r++) {
      final row = controller.activeBuffer.getAbsoluteRow(r);

      TextPainter? tp = controller.getCachedRow(row);
      if (tp == null) {
        final cells = row.cells;
        final rowCols = cells.length;
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
          )..layout(minWidth: 0, maxWidth: cols * cellW);
          controller.cacheRow(row, tp);
        }
      }

      if (tp != null) {
        tp.paint(canvas, Offset(0, r * cellH));
      }
    }

    // don't draw cursor in read-only mode
    if (readOnly) {
      return;
    }

    final visibleCursorRow = controller.activeBuffer.cursorRow;
    final visibleCursorCol = controller.activeBuffer.cursorCol;
    final absCursorRow =
        controller.activeBuffer.currentScrollback + visibleCursorRow;

    if (controller.cursor.visible &&
        absCursorRow >= 0 &&
        absCursorRow < totalRows &&
        visibleCursorCol >= 0 &&
        visibleCursorCol < cols) {
      final cell = controller.activeBuffer.getAbsoluteCell(
        absCursorRow,
        visibleCursorCol,
      );
      final cellFg = cell.fmt.effectiveFgColor;
      final cellBg = cell.fmt.effectiveBgColor;

      final Color fillColor = cellFg ?? controller.theme.foregroundColor;
      final Color charColor = cellBg ?? controller.theme.backgroundColor;

      final cursorRect = Rect.fromLTWH(
        visibleCursorCol * cellW,
        absCursorRow * cellH,
        cellW,
        cellH,
      );

      switch (controller.cursor.style) {
        case .block:
          canvas.drawRect(cursorRect, Paint()..color = fillColor);
          // re-draw the character with inverted color
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
            ..layout(minWidth: 0, maxWidth: cellW)
            ..paint(
              canvas,
              Offset(visibleCursorCol * cellW, absCursorRow * cellH),
            );
          break;

        case .underline:
          final underlineHeight = cellH * 0.18;
          final underlineRect = Rect.fromLTWH(
            visibleCursorCol * cellW,
            (absCursorRow + 1) * cellH - underlineHeight,
            cellW,
            underlineHeight,
          );
          canvas.drawRect(underlineRect, Paint()..color = fillColor);
          break;

        case .bar:
          final barWidth = max(1.0, cellW * 0.12);
          final barRect = Rect.fromLTWH(
            visibleCursorCol * cellW,
            absCursorRow * cellH,
            barWidth,
            cellH,
          );
          canvas.drawRect(barRect, Paint()..color = fillColor);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant TerminalPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.readOnly != readOnly;
  }
}
