import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:cliq_term/src/rendering/terminal_painter.dart';
import 'package:cliq_term/src/state/selection.state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/cursor.state.dart';

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

  /// Interval for cursor blinking.
  final Duration cursorBlinkInterval;

  /// Maximum number of lines to keep in the scrollback buffer. Older lines will be discarded when this limit is exceeded.
  final int maxScrollbackLines;

  /// Whether to log parsed (and missing!) escape sequences and control characters to the console for debugging.
  final bool debugLogging;

  /// A callback that is fired when the terminal is resized, providing the new number of rows and columns.
  final void Function(int, int)? onResize;

  /// A callback that is fired when the terminal title is changed via an escape sequence, providing the new title string.
  final void Function(String)? onTitleChange;

  /// A callback that is fired when a bell character (0x07) is received.
  final void Function()? onBell;

  void Function(String)? onInput;
  TerminalTypography _typography;
  TerminalTheme _theme;

  late final EscapeParser _escapeParser = EscapeParser(controller: this);

  /// The main (front) buffer, which holds the primary terminal content and scrollback.
  late TerminalBuffer _front = TerminalBuffer(
    rows: rows,
    cols: cols,
    maxScrollbackLines: maxScrollbackLines,
  );

  /// The alternate (back) buffer, used for applications that switch to an alternate screen (e.g. vim, less).
  late TerminalBuffer _back = TerminalBuffer(
    rows: rows,
    cols: cols,
    maxScrollbackLines: TerminalBuffer.minMaxScrollbackLines,
    isBackBuffer: true,
  );

  /// Number of visible rows and columns (excluding scrollback).
  /// These are set via [resize] and used for rendering and input coordinate calculations.
  int rows, cols;

  /// Whether to render the back buffer instead of the front buffer.
  /// This is toggled by [useBackBuffer] and [useMainBuffer].
  bool backBufferActive = false;

  /// The answerback (ENQ) string.
  /// https://terminalguide.namepad.de/seq/a_c0-e/
  String answerback = '';

  /// The active text selection state.
  SelectionState selection = .new();

  /// The cursor state.
  CursorState cursor = .new();

  TerminalController({
    required this._typography,
    required this._theme,
    this.cursorBlinkInterval = const Duration(milliseconds: 600),
    this.maxScrollbackLines = TerminalBuffer.defaultMaxScrollbackLines,
    this.debugLogging = false,
    this.onInput,
    this.onResize,
    this.onTitleChange,
    this.onBell,
    this.rows = 24,
    this.cols = 80,
  });

  TerminalTheme get theme => _theme;
  TerminalTypography get typography => _typography;
  TerminalBuffer get activeBuffer => backBufferActive ? _back : _front;
  int get totalRows =>
      backBufferActive ? rows : (_front.currentScrollback + rows);

  /// Automatically resizes the terminal based on the provided [size] and current typography settings.
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
    // do nothing if size is unchanged
    if (newRows == rows && newCols == cols) return;
    onResize?.call(newRows, newCols);

    rows = newRows;
    cols = newCols;
    // resize buffers
    _front = _front.resize(newRows: newRows, newCols: newCols);
    _back = _back.resize(newRows: newRows, newCols: newCols);

    _front.resetVerticalMargins();
    _back.resetVerticalMargins();

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
      _front.saveCursor();
      _back.clear();
      _back.resetVerticalMargins();
    }

    backBufferActive = true;
    notifyListeners();
  }

  /// Leave the alternate (back) screen.
  /// If [restoreMain] is true, restore the front buffer's saved cursor/format (DECRC-like).
  void useMainBuffer({bool restoreMain = true}) {
    backBufferActive = false;

    if (restoreMain) {
      _front.restoreCursor();
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

  void feed(String input) {
    _escapeParser.write(input);
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
    cursor = cursor.copyWith(
      visible: true,
      //      timer: Timer.periodic(cursorBlinkInterval, (_) {
      //        cursor = cursor.copyWith(visible: !cursor.visible);
      //        notifyListeners();
      //      }),
    );
  }

  /// Begin text selection at visible [row],[col]
  void startSelection(int row, int col) {
    final int selectionStartRow = row.clamp(0, max(0, rows - 1));
    final int selectionStartCol = col.clamp(0, max(0, cols - 1));

    selection = selection.copyWith(
      active: true,
      startRow: selectionStartRow,
      startCol: selectionStartCol,
      endRow: selectionStartRow,
      endCol: selectionStartCol,
    );

    notifyListeners();
  }

  /// Update the selection end to visible [row],[col]
  void updateSelection(int row, int col) {
    if (!selection.active) return;

    selection = selection.copyWith(
      endRow: row.clamp(0, max(0, rows - 1)),
      endCol: col.clamp(0, max(0, cols - 1)),
    );

    notifyListeners();
  }

  /// Clear the active selection
  void clearSelection() {
    selection = .new();
    notifyListeners();
  }

  /// Return the selected text (if selection active) using visible coordinates.
  String? getSelectedText() {
    if (!selection.isSelectionActive) {
      return null;
    }

    return activeBuffer.exportSelection(
      selection.startRow!,
      selection.startCol!,
      selection.endRow!,
      selection.endCol!,
    );
  }

  /// Stops the cursor blinking timer.
  void stopCursorBlink() {
    cursor.timer?.cancel();
    cursor = cursor.copyWith(visible: true, timer: null);

    notifyListeners();
  }

  @override
  void dispose() {
    cursor.timer?.cancel();
    super.dispose();
  }
}
