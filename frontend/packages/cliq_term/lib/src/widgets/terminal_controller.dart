import 'dart:async';
import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:cliq_term/src/state/selection.state.dart';
import 'package:cliq_term/src/widgets/terminal_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CursorStyle { block, underline, bar }

/// Controller for managing terminal state, including buffers, cursor, and input handling.
class TerminalController extends ChangeNotifier {
  static const int _maxCacheSize = 500;
  static const int highWaterMark = 64 * 1024; // 64 KiB
  static const int lowWaterMark = 0; // 0 Bytes -> clear buffer

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

  static final Map<LogicalKeyboardKey, String> _appCursorKeyMap = {
    .arrowUp: '${kSeqEscape}OA',
    .arrowDown: '${kSeqEscape}OB',
    .arrowRight: '${kSeqEscape}OC',
    .arrowLeft: '${kSeqEscape}OD',
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

  /// A callback that is fired when the terminal is resized, providing the new number of rows and columns
  /// and the new size in pixels.
  final void Function(int, int, Size)? onResize;

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

  final Map<TerminalBufferRow, (int revision, TextPainter painter)> _rowCache =
      {};

  /// Number of visible rows and columns (excluding scrollback).
  /// These are set via [resize] and used for rendering and input coordinate calculations.
  int rows, cols;

  /// The current width and height of the terminal in pixels.
  /// These are set via [resize].
  double width, height;

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

  /// The current window title, as set via OSC 0/2 or restored from the title stack.
  String currentTitle = '';

  /// Stack used by XTWINOPS (CSI 22/23 t) to push/pop the window title.
  final List<String> _titleStack = [];

  /// Whether arrow keys send application-mode sequences (ESC O x) instead of
  /// the normal cursor-key sequences (ESC [ x), per DECCKM (CSI ?1h/l).
  bool applicationCursorKeys = false;

  /// Whether the terminal is currently in bracketed paste mode, which affects how pasted text is handled.
  bool bracketedPasteMode = false;

  /// Whether the terminal is currently in synchronized output mode, which affects how output is handled.
  bool synchronizedOutputActive = false;

  /// A watchdog timer that is used to detect when synchronized output mode has been active for too long and
  /// should be automatically disabled.
  Timer? _synchronizedOutputWatchdog;

  /// Whether the terminal has been modified since the last time it was marked clean.
  bool _isDirty = false;

  /// Whether the terminal is currently paused due to high input queue length.
  bool _isPaused = false;

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
    this.width = 800,
    this.height = 600,
  });

  /// Returns the current theme settings used for rendering the terminal, including colors and styles.
  TerminalTheme get theme => _theme;

  /// Returns the current typography settings used for rendering text in the terminal.
  TerminalTypography get typography => _typography;

  /// Returns the currently active buffer, which is either the front buffer or the back buffer depending on [backBufferActive].
  TerminalBuffer get activeBuffer => backBufferActive ? _back : _front;

  /// Returns the total number of rows in the terminal, including scrollback.
  int get totalRows =>
      backBufferActive ? rows : (_front.currentScrollback + rows);

  /// Whether the terminal has been modified since the last time it was marked clean.
  /// This is used to determine if a repaint is needed.
  bool get isDirty => _isDirty;

  /// Whether the terminal is currently paused due to high input queue length.
  bool get isPaused => _isPaused;

  /// Returns a cached [TextPainter] for the given [row] if it exists and is valid (matching the row's revision).
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

  void clearCache() => _rowCache.clear();

  void clearDirty() => _isDirty = false;

  void markDirty() {
    _isDirty = true;
    if (synchronizedOutputActive) return;
    notifyListeners();
  }

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

    final (cellW, cellH) = SingleRowPainter.measureChar(typography);
    final newCols = max(1, (size.width / cellW).floor());
    final newRows = max(1, (size.height / cellH).floor());

    if (newRows == rows && newCols == cols) return;
    resize(newRows, newCols, size);
  }

  /// Resizes the terminal to the specified number of rows and columns.
  void resize(int newRows, int newCols, Size newSize) {
    // do nothing if size is unchanged
    if (newRows == rows && newCols == cols) return;
    onResize?.call(newRows, newCols, newSize);

    rows = newRows;
    cols = newCols;
    width = newSize.width;
    height = newSize.height;

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
    final key = applicationCursorKeys
        ? (_appCursorKeyMap[ev.logicalKey] ?? _keyCharacterMap[ev.logicalKey])
        : _keyCharacterMap[ev.logicalKey];
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

  // TODO: warn user about potential unsafe sequences
  void paste(String text) {
    if (text.isNotEmpty) {
      text = _stripTrailingNewlines(text);
      if (bracketedPasteMode) {
        onInput?.call('$kSeqEscape[200~$text$kSeqEscape[201~');
      } else {
        onInput?.call(text);
      }
    }
  }

  void setWindowTitle(String title) {
    currentTitle = title;
    onTitleChange?.call(title);
  }

  void pushWindowTitle([int mode = 0]) {
    _titleStack.add(currentTitle);
  }

  void popWindowTitle([int mode = 0]) {
    if (_titleStack.isNotEmpty) {
      setWindowTitle(_titleStack.removeLast());
    }
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

  /// Resets the cursor blink interval to the default value of 600 milliseconds and restarts the blink timer.
  void resetCursorBlinkInterval() =>
      setCursorBlinkInterval(const Duration(milliseconds: 600));

  void setCursorBlinkTimeout(Duration timeout) {
    cursorBlinkTimeout = timeout;
    _resetBlink();
  }

  void setCursorVisible(bool visible) {
    cursor = cursor.copyWith(enabled: visible);
    markDirty();
  }

  void feed(String input) {
    _escapeParser.write(input);
    _resetBlink();
  }

  void emit(String input) => onInput?.call(input);

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
      timer: cursorBlinkInterval == .zero
          ? null
          : Timer.periodic(cursorBlinkInterval, (_) {
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
        timer: cursorBlinkInterval == .zero
            ? null
            : Timer.periodic(cursorBlinkInterval, (_) {
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

  /// Enables or disables synchronized output mode, which affects how output is handled.
  /// https://github.com/contour-terminal/vt-extensions/blob/master/synchronized-output.md
  void setSynchronizedOutput(bool enabled) {
    if (enabled) {
      synchronizedOutputActive = true;
      _synchronizedOutputWatchdog?.cancel();

      // safety measure; if this is enabled and the program crashes/hangs before
      // disabling it, the display would otherwise freeze indefinitely
      _synchronizedOutputWatchdog = Timer(const Duration(seconds: 2), () {
        setSynchronizedOutput(false);
      });
    } else {
      synchronizedOutputActive = false;
      _synchronizedOutputWatchdog?.cancel();
      _synchronizedOutputWatchdog = null;
      markDirty();
    }
  }

  @override
  void dispose() {
    cursor.timer?.cancel();
    cursor.inactivityTimer?.cancel();
    _synchronizedOutputWatchdog?.cancel();
    cursorBlinkNotifier.dispose();
    super.dispose();
  }

  /// Strip trailing newlines from multiline text to prevent auto-execution.
  /// Returns trimmed text if multiline, otherwise returns original text.
  ///
  /// TODO: There is a escape code that prevents auto-execution of pasted commands, but it is not implemented atm.
  static String _stripTrailingNewlines(String text) {
    if (text.contains('\n') && text.endsWith('\n')) {
      return text.trimRight();
    }
    return text;
  }
}
