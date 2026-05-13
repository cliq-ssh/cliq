import 'dart:async';
import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/model/esc_terminator.dart';
import 'package:cliq_term/src/rendering/model/terminal_buffer.dart';
import 'package:cliq_term/src/parser/cc_parser.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:cliq_term/src/rendering/utils/terminal_shortcuts.dart';
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
  TerminalTypography _typography;
  TerminalTheme _theme;

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

  // Selection state (visible coordinates: 0..rows-1)
  bool selectionActive = false;
  int? selectionStartRow;
  int? selectionStartCol;
  int? selectionEndRow;
  int? selectionEndCol;

  TerminalController({
    required TerminalTypography typography,
    required TerminalTheme theme,
    this.cursorBlinkInterval = const Duration(milliseconds: 600),
    this.maxScrollbackLines = 1000,
    this.debugLogging = false,
    this.onInput,
    this.onResize,
    this.onTitleChange,
    this.onBell,
    this.rows = 0,
    this.cols = 0,
  }) : _typography = typography,
       _theme = theme;

  TerminalTheme get theme => _theme;
  TerminalTypography get typography => _typography;
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

    if (HardwareKeyboard.instance.isControlPressed) {
      final controlChar = TerminalShortcuts.controlCharacterForKey(
        ev.logicalKey,
      );
      if (controlChar != null) {
        onInput?.call(controlChar);
        return;
      }
    }

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
    } else if (key == LogicalKeyboardKey.delete) {
      onInput?.call('\x1b[3~');
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
    } else if (key == LogicalKeyboardKey.home) {
      onInput?.call('\x1b[H');
    } else if (key == LogicalKeyboardKey.end) {
      onInput?.call('\x1b[F');
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

  void setTerminalTheme(TerminalTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  void setTerminalTypography(TerminalTypography newTypography) {
    _typography = newTypography;
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

  /// Begin text selection at visible [row],[col]
  void startSelection(int row, int col) {
    selectionActive = true;
    selectionStartRow = row.clamp(0, max(0, rows - 1));
    selectionStartCol = col.clamp(0, max(0, cols - 1));
    selectionEndRow = selectionStartRow;
    selectionEndCol = selectionStartCol;
    notifyListeners();
  }

  /// Update the selection end to visible [row],[col]
  void updateSelection(int row, int col) {
    if (!selectionActive) return;
    selectionEndRow = row.clamp(0, max(0, rows - 1));
    selectionEndCol = col.clamp(0, max(0, cols - 1));
    notifyListeners();
  }

  /// Clear the active selection
  void clearSelection() {
    selectionActive = false;
    selectionStartRow = null;
    selectionStartCol = null;
    selectionEndRow = null;
    selectionEndCol = null;
    notifyListeners();
  }

  /// Return the selected text (if selection active) using visible coordinates.
  String? getSelectedText() {
    if (!selectionActive ||
        selectionStartRow == null ||
        selectionStartCol == null ||
        selectionEndRow == null ||
        selectionEndCol == null) {
      return null;
    }
    return activeBuffer.exportSelection(
      selectionStartRow!,
      selectionStartCol!,
      selectionEndRow!,
      selectionEndCol!,
    );
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
