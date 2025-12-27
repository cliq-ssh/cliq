import 'dart:async';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/model/esc_terminator.dart';
import 'package:cliq_term/src/model/terminal_buffer.dart';
import 'package:cliq_term/src/parser/cc_parser.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CursorStyle { block, underline, bar }

/// Controller for managing terminal state, including buffers, cursor, and input handling.
class TerminalController extends ChangeNotifier {
  final TerminalTypography typography;
  final TerminalColorTheme colors;
  final Duration cursorBlinkInterval;
  final void Function(int, int)? onResize;
  final void Function(String)? onTitleChange;
  final void Function()? onBell;
  void Function(String)? onInput;

  late TerminalBuffer front = TerminalBuffer(rows: rows, cols: cols);
  late TerminalBuffer back = TerminalBuffer(rows: rows, cols: cols);

  late final EscapeParser escapeParser = EscapeParser(
    controller: this,
    colors: colors,
  );
  late final ControlCharacterParser ccParser = ControlCharacterParser(
    controller: this,
  );

  int rows;
  int cols;
  int cursorRow = 0;
  int cursorCol = 0;
  FormattingOptions curFmt = FormattingOptions();
  CursorStyle cursorStyle = .bar;
  bool cursorVisible = true;
  Timer? _cursorTimer;

  TerminalController({
    required this.typography,
    required this.colors,
    this.cursorBlinkInterval = const Duration(milliseconds: 600),
    this.onInput,
    this.onResize,
    this.onTitleChange,
    this.onBell,
    this.rows = 0,
    this.cols = 0,
  });

  /// Resizes the terminal to the specified number of rows and columns.
  void resize(int newRows, int newCols) {
    if (newRows == rows && newCols == cols) return;
    onResize?.call(newRows, newCols);

    rows = newRows;
    cols = newCols;
    front = front.resize(newRows: newRows, newCols: newCols);
    back = back.resize(newRows: newRows, newCols: newCols);

    cursorRow = cursorRow.clamp(0, rows - 1);
    cursorCol = cursorCol.clamp(0, cols - 1);
    notifyListeners();
  }

  /// Handles keyboard input events and translates them into terminal input.
  /// Supports character input and special keys like Enter, Backspace, Tab, and Arrow keys.
  void handleKey(KeyEvent ev) {
    if (ev is! KeyDownEvent) return;

    final String? ch = ev.character;
    if (ch != null && ch.isNotEmpty) {
      onInput?.call(ch);
      return;
    }

    final key = ev.logicalKey;
    if (key == LogicalKeyboardKey.enter) {
      onInput?.call('\n');
    } else if (key == LogicalKeyboardKey.backspace) {
      onInput?.call('\x7f');
    } else if (key == LogicalKeyboardKey.tab) {
      onInput?.call('\t');
    } else if (key == LogicalKeyboardKey.arrowUp) {
      onInput?.call('\x1b[A');
    } else if (key == LogicalKeyboardKey.arrowDown) {
      onInput?.call('\x1b[B');
    } else if (key == LogicalKeyboardKey.arrowRight) {
      onInput?.call('\x1b[C');
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      onInput?.call('\x1b[D');
    }
  }

  /// Resets both front and back buffers, cursor position, and formatting.
  void resetBuffers() {
    front.clear();
    back.clear();
    cursorRow = 0;
    cursorCol = 0;
    curFmt.reset();
    notifyListeners();
  }

  /// Swaps the front and back buffers, clearing the new back buffer.
  void commitToBackBuffer() {
    front.clear();
    cursorRow = 0;
    cursorCol = 0;
    notifyListeners();
  }

  void writeChar(String ch) {
    if (rows == 0 || cols == 0) return;

    if (cursorRow < 0) cursorRow = 0;
    if (cursorCol < 0) cursorCol = 0;

    if (cursorCol >= cols) {
      cursorCol = 0;
      cursorRow++;
    }

    cursorVisible = true;
    _cursorTimer?.cancel();
    startCursorBlink();

    front.setCell(
      cursorRow,
      cursorCol,
      Cell(ch, FormattingOptions.clone(curFmt)),
    );
    cursorCol++;

    if (cursorCol >= cols) {
      cursorCol = 0;
      cursorRow++;
      if (cursorRow >= rows) {
        front.pushEmptyLine();
        cursorRow = rows - 1;
      }
    }
  }

  /// Feeds input string into the terminal, parsing escape sequences and control characters.
  void feed(String input) {
    int i = 0;
    while (i < input.length) {
      final cu = input.codeUnitAt(i);

      if (cu == EscTerminator.escCode) {
        final consumed = escapeParser.parse(input, i, curFmt);
        if (consumed <= 0) break; // incomplete sequence
        i += consumed;
        continue;
      }

      // handle control characters
      if (ccParser.parseCc(cu)) {
        i++;
        continue;
      }

      writeChar(String.fromCharCode(cu));
      i++;
    }

    notifyListeners();
  }

  /// Starts the cursor blinking timer.
  void startCursorBlink() {
    _cursorTimer?.cancel();
    cursorVisible = true;
    _cursorTimer = Timer.periodic(cursorBlinkInterval, (_) {
      cursorVisible = !cursorVisible;
      notifyListeners();
    });
  }

  /// Stops the cursor blinking timer.
  void stopCursorBlink() {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    cursorVisible = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }
}
