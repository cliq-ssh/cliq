import 'dart:math';

import 'package:flutter/material.dart';

import '../../cliq_term.dart';

class TerminalPainter extends CustomPainter {
  final TerminalController controller;

  const TerminalPainter(this.controller);

  /// Calculates the width and height of a single character cell based on the provided typography.
  static (double width, double height) measureChar(
    TerminalTypography typography,
  ) {
    final probe = TextPainter(
      text: TextSpan(text: 'MMMM', style: typography.toTextStyle()),
      textDirection: TextDirection.ltr,
    )..layout();
    return (probe.width / 4, probe.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // set background
    final bgPaint = Paint()..color = controller.colors.backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final (cellW, cellH) = measureChar(controller.typography);
    final rows = controller.front.rows;
    final cols = (rows > 0) ? controller.front.cols : 0;

    if (rows == 0 || cols == 0) return;

    // draw cell backgrounds
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cellBg = controller.front.getCell(r, c).fmt.bgColor;
        if (cellBg != null) {
          final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
          final p = Paint()..color = cellBg;
          canvas.drawRect(rect, p);
        }
      }
    }

    // paint text for each row
    for (int r = 0; r < rows; r++) {
      FormattingOptions? lastFmt;
      final List<InlineSpan> spans = [];
      final StringBuffer sb = StringBuffer();

      // helper to flush current run
      void flushRun() {
        if (sb.isEmpty) return;
        final fmt = lastFmt ?? FormattingOptions();
        final effectiveFg = fmt.concealed
            ? controller.colors.foregroundColor.withAlpha(0)
            : (fmt.fgColor ?? controller.colors.foregroundColor);

        final style = controller.typography.toTextStyle().copyWith(
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
        final cell = controller.front.getCell(r, c);
        final fmt = cell.fmt;
        if (lastFmt == null) {
          lastFmt = fmt;
        } else if (lastFmt != fmt) {
          flushRun();
          lastFmt = fmt;
        }
        sb.write(cell.ch);
      }
      flushRun();

      // skip empty rows
      if (spans.isEmpty) continue;

      TextPainter(
          text: TextSpan(children: spans),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )
        ..layout(minWidth: 0, maxWidth: cols * cellW)
        ..paint(canvas, Offset(0, r * cellH));
    }

    final cr = controller.cursorRow;
    final cc = controller.cursorCol;
    if (controller.cursorVisible &&
        cr >= 0 &&
        cr < rows &&
        cc >= 0 &&
        cc < cols) {
      final cell = controller.front.getCell(cr, cc);
      final cellFg = cell.fmt.fgColor;
      final cellBg = cell.fmt.bgColor;

      final Color fillColor = cellFg ?? controller.colors.foregroundColor;
      final Color charColor = cellBg ?? controller.colors.backgroundColor;

      final cursorRect = Rect.fromLTWH(cc * cellW, cr * cellH, cellW, cellH);

      switch (controller.cursorStyle) {
        case CursorStyle.block:
          canvas.drawRect(cursorRect, Paint()..color = fillColor);
          // re-draw the character with inverted color (charColor)
          final displayedChar = cell.ch.isEmpty ? ' ' : cell.ch;
          final charStyle = TextStyle(
            color: charColor,
            fontSize: controller.typography.fontSize,
            fontFamily: controller.typography.fontFamily,
            fontWeight: cell.fmt.bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: cell.fmt.italic ? FontStyle.italic : FontStyle.normal,
          );
          TextPainter(
              text: TextSpan(text: displayedChar, style: charStyle),
              textDirection: TextDirection.ltr,
            )
            ..layout(minWidth: 0, maxWidth: cellW)
            ..paint(canvas, Offset(cc * cellW, cr * cellH));
          break;

        case CursorStyle.underline:
          final underlineHeight = cellH * 0.18;
          final underlineRect = Rect.fromLTWH(
            cc * cellW,
            (cr + 1) * cellH - underlineHeight,
            cellW,
            underlineHeight,
          );
          canvas.drawRect(underlineRect, Paint()..color = fillColor);
          break;

        case CursorStyle.bar:
          final barWidth = max(1.0, cellW * 0.12);
          final barRect = Rect.fromLTWH(
            cc * cellW,
            cr * cellH,
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
    return oldDelegate.controller != controller;
  }
}
