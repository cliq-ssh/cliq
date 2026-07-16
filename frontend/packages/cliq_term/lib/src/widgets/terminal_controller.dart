import 'dart:async';
import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:cliq_term/src/widgets/terminal_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CursorStyle { block, underline, bar }

/// Controller for managing terminal state, including buffers, cursor, and input handling.
class TerminalController extends ChangeNotifier {
  static final Map<LogicalKeyboardKey, String> _keyCharacterMap = {
    .enter: '\r',
    .backspace: '\x7f',
    .tab: kSeqTab,
    .escape: kSeqEscape,
    .arrowUp: kSeqCursorUp,
    .arrowDown: kSeqCursorDown,
    .arrowRight: kSeqCursorRight,
    .arrowLeft: kSeqCursorLeft,
    .home: '$kSeqEscape[H',
    .end: '$kSeqEscape[F',
    .insert: '$kSeqEscape[2~',
    .delete: '$kSeqEscape[3~',
    .pageUp: '$kSeqEscape[5~',
    .pageDown: '$kSeqEscape[6~',
    .f1: '${kSeqEscape}OP',
    .f2: '${kSeqEscape}OQ',
    .f3: '${kSeqEscape}OR',
    .f4: '${kSeqEscape}OS',
    .f5: '$kSeqEscape[15~',
    .f6: '$kSeqEscape[17~',
    .f7: '$kSeqEscape[18~',
    .f8: '$kSeqEscape[19~',
    .f9: '$kSeqEscape[20~',
    .f10: '$kSeqEscape[21~',
    .f11: '$kSeqEscape[23~',
    .f12: '$kSeqEscape[24~',
  };

  /// Interval for cursor blinking.
  Duration cursorBlinkInterval;

  /// Time of inactivity before the cursor stops blinking.
  Duration cursorBlinkTimeout;

  /// Whether the cursor is currently in the "on" phase of blinking.
  final ValueNotifier<bool> cursorBlinkNotifier = ValueNotifier(true);

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

  /// A callback that is fired when the input queue exceeds the high water mark.
  void Function()? onPause;

  /// A callback that is fired when the input queue drops below the low water mark.
  void Function()? onResume;

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

  final Map<TerminalBufferRow, (int revision, TextPainter painter)> _rowCache =
      {};
  static const int _maxCacheSize = 500;

  TextPainter? getCachedRow(TerminalBufferRow row) {
    final cached = _rowCache.remove(row);
    if (cached != null) {
      if (cached.$1 == row.revision) {
        _rowCache[row] = cached; // Move to end (MRU)
        return cached.$2;
      }
      // Revision mismatch, don't put it back, effectively evicting it
    }
    return null;
  }

  void cacheRow(TerminalBufferRow row, TextPainter painter) {
    if (_rowCache.length >= _maxCacheSize) {
      // LinkedHashMap iterates in insertion order, so the first element is the LRU
      final firstKey = _rowCache.keys.first;
      _rowCache.remove(firstKey);
    }
    _rowCache[row] = (row.revision, painter);
  }

  void clearCache() {
    _rowCache.clear();
  }

  bool _isDirty = false;
  bool get isDirty => _isDirty;

  void markDirty() {
    _isDirty = true;
    notifyListeners();
  }

  void clearDirty() {
    _isDirty = false;
  }

  static const int highWaterMark = 64 * 1024; // 64 KiB
  static const int lowWaterMark = 0; // 0 Bytes -> clear buffer
  bool _isPaused = false;

  bool get isPaused => _isPaused;

  TerminalController({
    required this._typography,
    required this._theme,
    this.cursorBlinkInterval = const Duration(milliseconds: 600),
    this.cursorBlinkTimeout = const Duration(seconds: 10),
    this.maxScrollbackLines = TerminalBuffer.defaultMaxScrollbackLines,
    this.debugLogging = false,
    this.onInput,
    this.onResize,
    this.onTitleChange,
    this.onBell,
    this.onPause,
    this.onResume,
    this.rows = 24,
    this.cols = 80,
  });

  TerminalTheme get theme => _theme;
  TerminalTypography get typography => _typography;
  TerminalBuffer get activeBuffer => backBufferActive ? _back : _front;
  int get totalRows =>
      backBufferActive ? rows : (_front.currentScrollback + rows);

  void pause() {
    _isPaused = true;
    onPause?.call();
  }

  void resume() {
    _isPaused = false;
    onResume?.call();
  }

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

    clearCache();
    markDirty();
    notifyListeners();
  }

  /// Handles keyboard input events and translates them into terminal input.
  /// Supports character input and special keys like Enter, Backspace, Tab, and Arrow keys.
  void handleKey(KeyEvent ev) {
    if (ev is! KeyDownEvent && ev is! KeyRepeatEvent) {
      return;
    }

    _resetBlink();

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
    markDirty();
    notifyListeners();
  }

  /// Leave the alternate (back) screen.
  /// If [restoreMain] is true, restore the front buffer's saved cursor/format (DECRC-like).
  void useMainBuffer({bool restoreMain = true}) {
    backBufferActive = false;

    if (restoreMain) {
      _front.restoreCursor();
    }

    markDirty();
    notifyListeners();
  }

  void setTerminalTheme(TerminalTheme theme) {
    _theme = theme;
    clearCache();
    markDirty();
    notifyListeners();
  }

  void setTerminalTypography(TerminalTypography newTypography) {
    _typography = newTypography;
    clearCache();
    markDirty();
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

  void setCursorStyle(CursorStyle style) {
    cursor = cursor.copyWith(style: style);
    _resetBlink();
  }

  void setCursorBlinkInterval(Duration interval) {
    cursorBlinkInterval = interval;
    _resetBlink();
  }

  void setCursorBlinkTimeout(Duration timeout) {
    cursorBlinkTimeout = timeout;
    _resetBlink();
  }

  void feed(String input) {
    _escapeParser.write(input);
    _resetBlink();
  }

  /// Returns the number of characters currently waiting to be parsed.
  int get pendingInputLength => _escapeParser.queueLength;

  /// Sets the cursor position to the specified [row] and [col].
  void setCursorPosition(int row, int col) {
    activeBuffer.cursorRow = row;
    activeBuffer.cursorCol = col;
    _resetBlink();
    markDirty();
  }

  void setCursorPositionRow(int row) =>
      setCursorPosition(row, activeBuffer.cursorCol);
  void setCursorPositionCol(int col) =>
      setCursorPosition(activeBuffer.cursorRow, col);

  /// Starts the cursor blinking timer.
  void startCursorBlink() {
    stopCursorBlink();

    cursor = cursor.copyWith(
      enabled: true,
      blinkVisible: true,
      timer: Timer.periodic(cursorBlinkInterval, (_) {
        cursor = cursor.copyWith(blinkVisible: !cursor.blinkVisible);
        cursorBlinkNotifier.value = cursor.blinkVisible;
      }),
    );
    cursorBlinkNotifier.value = true;
    _resetInactivityTimer();
  }

  void _resetBlink() {
    if (cursor.timer != null) {
      cursor = cursor.copyWith(blinkVisible: true);
      cursorBlinkNotifier.value = true;
      // Restart the periodic timer to align the blink phase with the activity
      cursor.timer?.cancel();
      cursor = cursor.copyWith(
        timer: Timer.periodic(cursorBlinkInterval, (_) {
          cursor = cursor.copyWith(blinkVisible: !cursor.blinkVisible);
          cursorBlinkNotifier.value = cursor.blinkVisible;
        }),
      );
    }
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    cursor.inactivityTimer?.cancel();

    if (cursorBlinkTimeout == Duration.zero) {
      return;
    }

    cursor = cursor.copyWith(
      inactivityTimer: Timer(cursorBlinkTimeout, () {
        cursor.timer?.cancel();
        cursor = cursor.copyWith(blinkVisible: true, timer: null);
        cursorBlinkNotifier.value = true;
      }),
    );
  }

  /// Begin text selection at absolute [row],[col]
  void startSelection(int row, int col) {
    final int selectionStartRow = row.clamp(0, max(0, totalRows - 1));
    final int selectionStartCol = col.clamp(0, max(0, cols - 1));

    selection = selection.copyWith(
      active: true,
      startRow: selectionStartRow,
      startCol: selectionStartCol,
      endRow: selectionStartRow,
      endCol: selectionStartCol,
    );

    markDirty();
  }

  /// Update the selection end to absolute [row],[col]
  void updateSelection(int row, int col) {
    if (!selection.active) return;

    selection = selection.copyWith(
      endRow: row.clamp(0, max(0, totalRows - 1)),
      endCol: col.clamp(0, max(0, cols - 1)),
    );

    markDirty();
  }

  /// Clear the active selection
  void clearSelection() {
    selection = .new();
    markDirty();
  }

  /// Return the selected text (if selection active) using absolute coordinates.
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
    cursor.inactivityTimer?.cancel();
    cursor = cursor.copyWith(
      enabled: true,
      blinkVisible: true,
      timer: null,
      inactivityTimer: null,
    );
    cursorBlinkNotifier.value = true;
  }

  @override
  void dispose() {
    cursor.timer?.cancel();
    cursor.inactivityTimer?.cancel();
    cursorBlinkNotifier.dispose();
    super.dispose();
  }
}
