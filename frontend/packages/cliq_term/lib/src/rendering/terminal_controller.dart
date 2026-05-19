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
  static final Map<LogicalKeyboardKey, String> _keyCharacterMap = {
    .enter: '\r',
    .backspace: '\x7f',
    .tab: '\t',
    .escape: '\x1b',
    .arrowUp: '\x1b[A',
    .arrowDown: '\x1b[B',
    .arrowRight: '\x1b[C',
    .arrowLeft: '\x1b[D',
    .home: '\x1b[H',
    .end: '\x1b[F',
    .insert: '\x1b[2~',
    .delete: '\x1b[3~',
    .pageUp: '\x1b[5~',
    .pageDown: '\x1b[6~',
    .f1: '\x1bOP',
    .f2: '\x1bOQ',
    .f3: '\x1bOR',
    .f4: '\x1bOS',
    .f5: '\x1b[15~',
    .f6: '\x1b[17~',
    .f7: '\x1b[18~',
    .f8: '\x1b[19~',
    .f9: '\x1b[20~',
    .f10: '\x1b[21~',
    .f11: '\x1b[23~',
    .f12: '\x1b[24~',
  };

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
    required this._typography,
    required this._theme,
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
    if (ev is! KeyDownEvent && ev is! KeyRepeatEvent) {
      return;
    }

    // We seem to need extra control key handling for Windows here since [ev.character] is always
    // null when Ctrl is pressed.
    // See https://github.com/cliq-ssh/cliq/pull/481#issuecomment-4472584212
    //
    // This should streamline input for all platforms.
    if (HardwareKeyboard.instance.isControlPressed) {
      final key = ev.logicalKey.keyId - 'a'.codeUnitAt(0);
      if (key >= 0 && key < 26) {
        onInput?.call(String.fromCharCode(key + 1));
        return;
      }
    }

    final String? char = ev.character;

    // simply pass character input if available
    if (char != null && char.isNotEmpty) {
      onInput?.call(char);
      return;
    }

    // otherwise check for special keys
    final key = _keyCharacterMap[ev.logicalKey];
    if (key != null) {
      onInput?.call(key);
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
