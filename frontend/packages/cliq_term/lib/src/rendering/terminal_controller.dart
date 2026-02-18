import 'dart:async';
import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/model/esc_terminator.dart';
import 'package:cliq_term/src/rendering/model/terminal_buffer.dart';
import 'package:cliq_term/src/parser/cc_parser.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CursorStyle { block, underline, bar }

/// Controller for managing terminal state, including buffers, cursor, and input handling.
class TerminalController extends ChangeNotifier {
  final Duration cursorBlinkInterval;
  final int maxScrollbackLines;
  final bool debugLogging;
  final void Function(int, int)? onResize;
  final void Function(String)? onTitleChange;
  final void Function()? onBell;
  void Function(String)? onInput;
  TerminalTypography typography;
  TerminalTheme theme;

  late TerminalBuffer front = TerminalBuffer(
    rows: rows,
    cols: cols,
    maxScrollbackLines: maxScrollbackLines,
  );
  late TerminalBuffer back = TerminalBuffer(
    rows: rows,
    cols: cols,
    maxScrollbackLines: 0,
    isBackBuffer: true,
  );

  late final EscapeParser escapeParser = EscapeParser(
    controller: this,
    colors: theme,
  );
  late final ControlCharacterParser ccParser = ControlCharacterParser(
    controller: this,
  );

  int rows;
  int cols;
  bool backBufferActive = false;
  CursorStyle cursorStyle = .bar;
  bool cursorVisible = true;
  Timer? _cursorTimer;

  TerminalController({
    required this.typography,
    required this.theme,
    this.cursorBlinkInterval = const Duration(milliseconds: 600),
    this.maxScrollbackLines = 1000,
    this.debugLogging = false,
    this.onInput,
    this.onResize,
    this.onTitleChange,
    this.onBell,
    this.rows = 0,
    this.cols = 0,
  });

  TerminalBuffer get activeBuffer => backBufferActive ? back : front;
  int get totalRows => front.currentScrollback + rows;

  void fitResize(Size size) {
    if (!size.width.isFinite || !size.height.isFinite) {
      return;
    }

    final (cellW, cellH) = TerminalPainter.measureChar(typography);
    final newCols = max(1, (size.width / cellW).floor());
    final newRows = max(1, (size.height / cellH).floor());

    if (newRows == rows && newCols == cols) return;
    resize(newRows, newCols);
  }

  /// Resizes the terminal to the specified number of rows and columns.
  void resize(int newRows, int newCols) {
    if (newRows == rows && newCols == cols) return;
    onResize?.call(newRows, newCols);

    rows = newRows;
    cols = newCols;
    front = front.resize(newRows: newRows, newCols: newCols);
    back = back.resize(newRows: newRows, newCols: newCols);

    front.resetVerticalMargins();
    back.resetVerticalMargins();

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

  /// Enter the alternate (back) screen.
  /// If [saveMainAndClear] is true, save the front buffer's cursor/format (DECSC-like).
  void useBackBuffer({bool saveMainAndClear = true}) {
    if (saveMainAndClear) {
      front.saveCursor();
      back.clear();
      back.resetVerticalMargins();
    }

    backBufferActive = true;
    notifyListeners();
  }

  /// Leave the alternate (back) screen.
  /// If [restoreMain] is true, restore the front buffer's saved cursor/format (DECRC-like).
  void useMainBuffer({bool restoreMain = true}) {
    backBufferActive = false;

    if (restoreMain) {
      front.restoreCursor();
    }

    notifyListeners();
  }

  void setInsertMode(bool enabled) {
    activeBuffer.isInsertMode = enabled;
    notifyListeners();
  }

  void setLineFeedMode(bool enabled) {
    activeBuffer.isLineFeedMode = enabled;
    notifyListeners();
  }

  void setAutoWrapMode(bool enabled) {
    activeBuffer.isAutoWrapMode = enabled;
    notifyListeners();
  }

  /// Feeds input string into the terminal, parsing escape sequences and control characters.
  void feed(String input) {
    int i = 0;
    while (i < input.length) {
      final cu = input.codeUnitAt(i);

      if (cu == EscTerminator.escCode) {
        final consumed = escapeParser.parse(
          input,
          i,
          activeBuffer.currentFormat,
        );
        if (consumed <= 0) break; // incomplete sequence
        i += consumed;
        continue;
      }

      // handle control characters
      if (ccParser.parseCc(cu)) {
        i++;
        continue;
      }

      activeBuffer.printChar(cu);
      i++;
    }

    notifyListeners();
  }

  /// Sets the cursor position to the specified [row] and [col].
  void setCursorPosition(int row, int col) {
    activeBuffer.cursorRow = row;
    activeBuffer.cursorCol = col;
    notifyListeners();
  }

  void setCursorPositionRow(int row) =>
      setCursorPosition(row, activeBuffer.cursorCol);
  void setCursorPositionCol(int col) =>
      setCursorPosition(activeBuffer.cursorRow, col);

  /// Starts the cursor blinking timer.
  void startCursorBlink() {
    _cursorTimer?.cancel();
    cursorVisible = true;
    //_cursorTimer = Timer.periodic(cursorBlinkInterval, (_) {
    //  cursorVisible = !cursorVisible;
    //  notifyListeners();
    //});
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
