import 'dart:ui';

import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

class TerminalTestUtils {
  static const _defaultTheme = TerminalTheme(
    backgroundColor: Color(0xFF000000),
    foregroundColor: Color(0xFFFFFFFF),
    cursorColor: Color(0xFFFFFFFF),
    selectionColor: Color(0xFF555555),
    black: Color(0xFF000000),
    red: Color(0xFFFF5555),
    green: Color(0xFF55FF55),
    yellow: Color(0xFFFFFF55),
    blue: Color(0xFF5555FF),
    purple: Color(0xFFFF55FF),
    cyan: Color(0xFF55FFFF),
    white: Color(0xFFFFFFFF),
    brightBlack: Color(0xFF555555),
    brightRed: Color(0xFFFF5555),
    brightGreen: Color(0xFF55FF55),
    brightYellow: Color(0xFFFFFF55),
    brightBlue: Color(0xFF5555FF),
    brightPurple: Color(0xFFFF55FF),
    brightCyan: Color(0xFF55FFFF),
    brightWhite: Color(0xFFFFFFFF),
  );

  const TerminalTestUtils._();

  /// Creates a [TerminalController] with the default theme and typography for testing purposes.
  static TerminalController createController({void Function()? onBell}) =>
      TerminalController(
        theme: _defaultTheme,
        typography: TerminalTypography(
          fontFamily: 'Jetbrains Mono',
          fontSize: 12,
        ),
        rows: 24,
        cols: 80,
        onBell: onBell,
      );

  /// Asserts that the cursor is at the expected position in the terminal.
  static void expectCursorAt(TerminalController controller, int row, int col) {
    final buffer = controller.activeBuffer;
    expect(buffer.cursorRow, row);
    expect(buffer.cursorCol, col);
  }

  /// Asserts that the cell at the specified position has the expected character and formatting.
  static void expectCellAt(
    TerminalController controller,
    int row,
    int col, {
    String? ch,
    Color? fgColor,
    Color? bgColor,
  }) {
    final cell = controller.activeBuffer.getAbsoluteCell(row, col);
    if (ch != null) {
      expect(
        cell.ch,
        ch,
        reason:
            'Expected cell at ($row, $col) to have character "$ch" but found "${cell.ch}"',
      );
    }
    if (fgColor != null) {
      expect(
        cell.fmt.fgColor,
        fgColor,
        reason:
            'Expected cell at ($row, $col) to have foreground color $fgColor but found ${cell.fmt.fgColor}',
      );
    }
    if (bgColor != null) {
      expect(
        cell.fmt.bgColor,
        bgColor,
        reason:
            'Expected cell at ($row, $col) to have background color $bgColor but found ${cell.fmt.bgColor}',
      );
    }
  }
}
