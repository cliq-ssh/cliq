import 'dart:math';

import 'package:flutter/material.dart';

import '../../cliq_term.dart';

class TerminalPainter extends CustomPainter {
  final TerminalController controller;
  final bool readOnly;

  const TerminalPainter(this.controller, {this.readOnly = false})
    : super(repaint: controller);

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

    // total rows available in the buffer (visible rows + scrollback (if any))
    final totalRows = controller.activeBuffer.length;
    final cols = controller.activeBuffer.cols;

    if (totalRows == 0 || cols == 0) return;

    // draw cell backgrounds for every buffer row
    for (int r = 0; r < totalRows; r++) {
      for (int c = 0; c < cols; c++) {
        final cell = controller.activeBuffer.getAbsoluteCell(r, c);
        final cellBg = cell.fmt.bgColor;
        if (cellBg != null) {
          final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
          final p = Paint()..color = cellBg;
          canvas.drawRect(rect, p);
        }
      }
    }

    // paint text for each buffer row
    for (int r = 0; r < totalRows; r++) {
      FormattingOptions? lastFmt;
      final List<InlineSpan> spans = [];
      final StringBuffer sb = StringBuffer();

      void flushRun() {
        if (sb.isEmpty) return;
        final fmt = lastFmt ?? FormattingOptions();
        final effectiveFg = fmt.concealed
            ? controller.colors.foregroundColor.withAlpha(0)
            : (fmt.effectiveFgColor ?? controller.colors.foregroundColor);

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
        final cell = controller.activeBuffer.getAbsoluteCell(r, c);
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

    // don't draw cursor in read-only mode
    if (readOnly) {
      return;
    }

    final visibleCursorRow = controller.activeBuffer.cursorRow;
    final visibleCursorCol = controller.activeBuffer.cursorCol;
    final absCursorRow =
        controller.activeBuffer.currentScrollback + visibleCursorRow;

    if (controller.cursorVisible &&
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

      final Color fillColor = cellFg ?? controller.colors.foregroundColor;
      final Color charColor = cellBg ?? controller.colors.backgroundColor;

      final cursorRect = Rect.fromLTWH(
        visibleCursorCol * cellW,
        absCursorRow * cellH,
        cellW,
        cellH,
      );

      switch (controller.cursorStyle) {
        case .block:
          canvas.drawRect(cursorRect, Paint()..color = fillColor);
          // re-draw the character with inverted color
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
  bool shouldRepaint(covariant TerminalPainter oldDelegate) => false;
}
