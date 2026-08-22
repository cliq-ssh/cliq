import 'dart:ui';

import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

class TerminalTestUtils {
  /// Dracula
  /// https://github.com/mbadolato/iTerm2-Color-Schemes/blob/0173c3cc154aab5d43b03241286d32372a87dec6/kitty/Dracula.conf
  static const _defaultTheme = TerminalTheme(
    black: Color(0xFF21222C),
    red: Color(0xFFFF5555),
    green: Color(0xFF50FA7B),
    yellow: Color(0xFFF1FA8C),
    blue: Color(0xFFBD93F9),
    purple: Color(0xFFFF79C6),
    cyan: Color(0xFF8BE9FD),
    white: Color(0xFFF8F8F2),
    brightBlack: Color(0xFF6272A4),
    brightRed: Color(0xFFFF6E6E),
    brightGreen: Color(0xFF69FF94),
    brightYellow: Color(0xFFFFFFA5),
    brightBlue: Color(0xFFD6ACFF),
    brightPurple: Color(0xFFFF92DF),
    brightCyan: Color(0xFFA4FFFF),
    brightWhite: Color(0xFFFFFFFF),
    background: Color(0xFF282A36),
    foreground: Color(0xFFF8F8F2),
    cursor: Color(0xFFF8F8F2),
    cursorText: Color(0xFF282A36),
    selectionBackground: Color(0xFF44475A),
    selectionForeground: Color(0xFF282A36),
  );

  const TerminalTestUtils._();

  /// Creates a [TerminalController] with the default theme and typography for testing purposes.
  static TerminalController createController({
    void Function()? onBell,
    void Function(String)? onInput,
    void Function(String)? onTitleChange,
    bool defaultAlternateScrollMode = true,
  }) => TerminalController(
    theme: _defaultTheme,
    typography: TerminalTypography(fontFamily: 'Jetbrains Mono', fontSize: 12),
    rows: 24,
    cols: 80,
    onBell: onBell,
    onInput: onInput,
    onTitleChange: onTitleChange,
    defaultAlternateScrollMode: defaultAlternateScrollMode,
  );
}

/// Asserts that the cursor is at the expected position in the terminal.
void expectCursorAt(TerminalController controller, int row, int col) {
  final buffer = controller.activeBuffer;
  expect(buffer.cursorRow, row);
  expect(buffer.cursorCol, col);
}

/// Asserts that the cell at the specified position has the expected character and formatting.
void expectCellAt(
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
