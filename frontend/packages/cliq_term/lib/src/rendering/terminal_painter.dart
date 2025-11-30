import 'package:flutter/material.dart';

import '../../cliq_term.dart';

class TerminalPainter extends CustomPainter {
  final TerminalController controller;
  final double fontSize;
  final Color defaultFg;
  final Color defaultBg;

  TerminalPainter(
    this.controller,
    this.fontSize,
    this.defaultFg,
    this.defaultBg,
  );

  static (double width, double height) measureChar(double fontSize) {
    final probe = TextPainter(
      text: TextSpan(
        text: 'MMMM',
        style: TextStyle(fontFamily: 'monospace', fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return (probe.width / 4, probe.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // set background
    final bgPaint = Paint()..color = defaultBg;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final (cellW, cellH) = measureChar(fontSize);
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
            ? defaultFg.withAlpha(0)
            : (fmt.fgColor ?? defaultFg);

        final style = TextStyle(
          color: effectiveFg,
          fontSize: fontSize,
          fontFamily: 'monospace',
          fontWeight: fmt.bold ? FontWeight.w700 : FontWeight.w400,
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

    // TODO: differentiate cursor styles
    // draw cursor
    final cr = controller.cursorRow;
    final cc = controller.cursorCol;
    if (cr >= 0 && cr < rows && cc >= 0 && cc < cols) {
      final cell = controller.front.getCell(cr, cc);
      final cellFg = cell.fmt.fgColor;
      final cellBg = cell.fmt.bgColor;

      Color cursorFill;
      if (cellBg != null && cellFg != null) {
        // invert using fg for fill to make text visible on cursor
        cursorFill = cellFg;
      } else if (cellBg != null) {
        cursorFill = cellBg.withValues(alpha: 0.9);
      } else {
        cursorFill = defaultFg;
      }

      final cursorRect = Rect.fromLTWH(cc * cellW, cr * cellH, cellW, cellH);
      final cursorPaint = Paint()..color = cursorFill;
      canvas.drawRect(cursorRect, cursorPaint);

      // re-draw the character on top of the cursor with inverted color (so char remains legible)
      final displayedChar = cell.ch.isEmpty ? ' ' : cell.ch;

      final charStyle = cell.fmt
          .toTextStyle(
            defaultFg: (cell.fmt.fgColor ?? defaultFg).withValues(alpha: 1),
            defaultBg: defaultBg,
            fontSize: fontSize,
          )
          .copyWith(backgroundColor: null);

      TextPainter(
          text: TextSpan(text: displayedChar, style: charStyle),
          textDirection: TextDirection.ltr,
        )
        ..layout(minWidth: 0, maxWidth: cellW)
        ..paint(canvas, Offset(cc * cellW, cr * cellH));
    }
  }

  @override
  bool shouldRepaint(covariant TerminalPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.fontSize != fontSize ||
        oldDelegate.defaultFg != defaultFg ||
        oldDelegate.defaultBg != defaultBg;
  }
}
