import 'dart:math';

import 'package:cliq_term/src/rendering/model/ring_buffer.dart';

import '../../../cliq_term.dart';

class Row {
  final List<Cell> cells;

  Row(int cols)
    : cells = List.generate(cols, (_) => Cell.empty(), growable: false);

  void clear() {
    for (var i = 0; i < cells.length; i++) {
      cells[i] = Cell.empty();
    }
  }
}

class TerminalBuffer {
  final int rows;
  final int cols;
  final int maxScrollbackLines;
  final bool isBackBuffer;

  final RingBuffer<Row> _buffer;

  /// The current formatting options.
  FormattingOptions currentFormat = FormattingOptions();

  /// The current cursor row position.
  int cursorRow = 0;

  /// The current cursor column position.
  int cursorCol = 0;

  int _topMargin;
  int _bottomMargin;

  int? savedCursorRow;
  int? savedCursorCol;
  FormattingOptions? savedFormat;

  bool isLineFeedMode = false;
  bool isInsertMode = false;

  bool isAutoWrapMode = false;

  /// Indicates whether the next character to be written should wrap to the next line
  /// and trigger an index operation
  bool pendingWrap = false;

  TerminalBuffer({
    required this.rows,
    required this.cols,
    this.maxScrollbackLines = 1000,
    this.isBackBuffer = false,
    this.isLineFeedMode = false,
  }) : _buffer = RingBuffer<Row>(rows + maxScrollbackLines),
       _topMargin = 0,
       _bottomMargin = rows - 1 {
    for (var i = 0; i < rows; i++) {
      _buffer.add(Row(cols));
    }
  }

  int get length => _buffer.length;
  int get currentScrollback => _buffer.length - rows;

  TerminalBuffer resize({required int newRows, required int newCols}) {
    final newBuffer = TerminalBuffer(
      rows: newRows,
      cols: newCols,
      maxScrollbackLines: maxScrollbackLines,
      isBackBuffer: isBackBuffer,
      isLineFeedMode: isLineFeedMode,
    );

    newBuffer.isAutoWrapMode = isAutoWrapMode;

    // absolute index in old ring
    final oldVisibleStart = currentScrollback;
    // absolute index in new ring
    final newVisibleStart = newBuffer.currentScrollback;

    final minRows = min(rows, newRows);
    final minCols = min(cols, newCols);

    for (var r = 0; r < minRows; r++) {
      final srcRow = _buffer[oldVisibleStart + r];
      final dstRow = newBuffer._buffer[newVisibleStart + r];

      // copy cell contents up to minCols
      for (var c = 0; c < minCols; c++) {
        dstRow.cells[c] = srcRow.cells[c];
      }
      // clear remaining columns in dst row if any
      for (var c = minCols; c < newCols; c++) {
        dstRow.cells[c] = Cell.empty();
      }
    }

    // Adjust cursor position
    newBuffer.cursorRow = min(cursorRow, newRows - 1);
    newBuffer.cursorCol = min(cursorCol, newCols - 1);
    return newBuffer;
  }

  /// Index (IND)
  /// - https://terminalguide.namepad.de/seq/a_esc_cd/
  void index() {
    if (isCursorInMargins()) {
      if (cursorRow == _bottomMargin) {
        if (isBackBuffer) {
          scrollUp(1);
        } else {
          pushEmptyLine();
        }
      } else {
        cursorDown(1);
      }
    } else if (cursorRow >= rows - 1) {
      if (isBackBuffer) {
        scrollUp(1);
      } else {
        pushEmptyLine();
      }
    } else {
      cursorDown(1);
    }
  }

  /// Reverse Index (RI)
  /// - https://terminalguide.namepad.de/seq/a_esc_cm/
  void reverseIndex() {
    if (isCursorInMargins()) {
      if (cursorRow == _topMargin) {
        scrollDown(1);
      } else {
        cursorUp(1);
      }
    } else if (cursorRow == 0) {
      // At top of buffer
      if (isBackBuffer) {
        scrollDown(1);
      } else {
        // Insert empty line at top
        _buffer.prepend(Row(cols));
        final topVisibleIdx = currentScrollback;
        _buffer[topVisibleIdx].clear();
      }
    } else {
      cursorUp(1);
    }
  }

  /// Line Feed (LF)
  /// - https://terminalguide.namepad.de/seq/a_c0-j/
  /// Vertical Tab (VT)
  /// - https://terminalguide.namepad.de/seq/a_c0-k/
  /// Form Feed (FF)
  /// - https://terminalguide.namepad.de/seq/a_c0-l/
  void lineFeed() {
    index();
    // If linefeed mode is set: Invoke carriage return
    if (isLineFeedMode) {
      carriageReturn();
    }
  }

  /// Carriage Return (CR)
  /// - https://terminalguide.namepad.de/seq/a_c0-m/
  void carriageReturn() => cursorCol = 0;

  /// Backspace (BS)
  /// - https://terminalguide.namepad.de/seq/a_c0-h/
  void backspace() => cursorLeft(1);

  /// Horizontal Tab (TAB)
  /// - https://terminalguide.namepad.de/seq/a_c0-i/
  void horizontalTab() {
    final nextTabStop = ((cursorCol ~/ 8) + 1) * 8;
    cursorCol = min(nextTabStop, cols - 1);
  }

  /// Returns a Cell by absolute index inside the ring buffer:
  /// index 0 is the oldest row; index `length-1` is the newest
  Cell getAbsoluteCell(int absRow, int col) {
    if (absRow < 0 || absRow >= _buffer.length) {
      return Cell.empty();
    }
    if (col < 0 || col >= cols) {
      return Cell.empty();
    }
    return _buffer[absRow].cells[col];
  }

  Cell getCell(int row, int col) {
    final abs = row + currentScrollback;
    if (abs < 0 || abs >= _buffer.length) return Cell.empty();
    if (col < 0 || col >= cols) return Cell.empty();
    return _buffer[abs].cells[col];
  }

  void setCell(int row, int col, Cell cell) {
    _buffer[row + currentScrollback].cells[col] = cell;
  }

  void setCellAtCursor(Cell cell) {
    setCell(cursorRow, cursorCol, cell);
  }

  void printString(String str) {
    for (final cu in str.runes) {
      printChar(cu);
    }
  }

  /// Prints a single character at the current cursor position.
  /// - https://terminalguide.namepad.de/printing/
  void printChar(int cu) {
    if (pendingWrap) {
      if (isAutoWrapMode) {
        index();
        cursorCol = 0;
      }
      pendingWrap = false;
    }

    if (isAutoWrapMode) {
      if (cursorCol >= cols) {
        index();
        cursorCol = 0;
      }
    } else {
      if (cursorCol >= cols) {
        cursorCol = max(0, cols);
      }
    }

    if (isInsertMode) {
      for (var c = cols - 1; c >= cursorCol + 1; c--) {
        final src = getCell(cursorRow, c - 1);
        setCell(cursorRow, c, src);
      }
      for (var c = cursorCol; c < min(cols, cursorCol + 1); c++) {
        setCell(cursorRow, c, Cell.empty());
      }
    }

    setCellAtCursor(
      Cell(String.fromCharCode(cu), FormattingOptions.clone(currentFormat)),
    );

    // whether the cursor is at the last column before printing
    final endsAtLastColumn = (cursorCol + 1 - 1) == (cols - 1);

    if (isAutoWrapMode && endsAtLastColumn) {
      cursorCol = cols - 1;
      pendingWrap = true;
    } else {
      cursorCol = min(cols - 1, cursorCol + 1);
    }
  }

  void clear() {
    _buffer.clear();
    for (var i = 0; i < rows; i++) {
      _buffer.add(Row(cols));
    }
    // reset cursor position
    cursorRow = 0;
    cursorCol = 0;
  }

  void pushEmptyLine() {
    _buffer.add(Row(cols));

    cursorRow = rows - 1;
    cursorCol = 0;
  }

  /// Scroll Up (SU)
  /// - https://terminalguide.namepad.de/seq/csi_cs/
  void scrollUp(int amount) {
    if (amount == 0) amount = 1;

    final visibleStart = currentScrollback;
    for (var i = _topMargin; i <= _bottomMargin; i++) {
      final destIdx = visibleStart + i;
      final srcRow = i + amount;
      if (srcRow <= _bottomMargin) {
        final srcIdx = visibleStart + srcRow;
        _buffer[destIdx] = _buffer[srcIdx];
      } else {
        _buffer[destIdx] = Row(cols);
      }
    }
  }

  /// Scroll Down (SD)
  /// - https://terminalguide.namepad.de/seq/csi_ct_1param/
  void scrollDown(int amount) {
    // first param is always != 0, otherwise it would be Track Mouse (https://terminalguide.namepad.de/seq/csi_ct_5param/)
    if (amount == 0) return;

    final visibleStart = currentScrollback;
    for (var i = _bottomMargin; i >= _topMargin; i--) {
      final destIdx = visibleStart + i;
      final srcRow = i - amount;
      if (srcRow >= _topMargin) {
        final srcIdx = visibleStart + srcRow;
        _buffer[destIdx] = _buffer[srcIdx];
      } else {
        _buffer[destIdx] = Row(cols);
      }
    }
  }

  /// Set Cursor Position (CUP)
  /// - https://terminalguide.namepad.de/seq/csi_ch/
  void setCursorPosition(int row, int col) {
    cursorRow = row.clamp(0, rows - 1);
    cursorCol = col.clamp(0, cols - 1);
  }

  /// Erase Line Right
  /// - https://terminalguide.namepad.de/seq/csi_ck-0/
  void eraseLineRight() {
    for (var c = cursorCol; c < cols; c++) {
      setCell(cursorRow, c, Cell.empty());
    }
  }

  /// Erase Line Left
  /// - https://terminalguide.namepad.de/seq/csi_ck-1/
  void eraseLineLeft() {
    for (var c = 0; c <= cursorCol; c++) {
      setCell(cursorRow, c, Cell.empty());
    }
  }

  /// Erase Line Complete
  /// - https://terminalguide.namepad.de/seq/csi_ck-2/
  void eraseLineComplete() {
    for (var c = 0; c < cols; c++) {
      setCell(cursorRow, c, Cell.empty());
    }
  }

  /// Erase Display Below
  /// - https://terminalguide.namepad.de/seq/csi_cj-0/
  void eraseDisplayBelow() {
    for (var r = cursorRow; r < rows; r++) {
      final startCol = r == cursorRow ? cursorCol : 0;
      for (var c = startCol; c < cols; c++) {
        setCell(r, c, Cell.empty());
      }
    }
  }

  /// Erase Display Above
  /// - https://terminalguide.namepad.de/seq/csi_cj-1/
  void eraseDisplayAbove() {
    for (var r = 0; r <= cursorRow; r++) {
      final endCol = r == cursorRow ? cursorCol : cols - 1;
      for (var c = 0; c <= endCol; c++) {
        setCell(r, c, Cell.empty());
      }
    }
  }

  /// Erase Display Complete
  /// - https://terminalguide.namepad.de/seq/csi_cj-2/
  void eraseDisplayComplete() => clear();

  /// Delete Character (DCH)
  /// - https://terminalguide.namepad.de/seq/csi_cp/
  void deleteCharacter(int amount) {
    if (!isCursorInMargins()) return;
    final start = cursorCol.clamp(0, cols);
    amount = min(amount, cols - start);

    // shift characters to the left
    for (var c = start; c < cols - amount; c++) {
      final cell = getCell(cursorRow, c + amount);
      setCell(cursorRow, c, cell);
    }

    // fill the vacated space with empty cells
    for (var c = cols - amount; c < cols; c++) {
      setCell(cursorRow, c, Cell.empty());
    }
  }

  /// Sets the vertical scroll margins to the specified [top] and [bottom] rows.
  /// Both [top] and [bottom] must be within the range of the buffer's rows.
  void setVerticalMargins(int top, int bottom) {
    _topMargin = max(0, min(top, rows - 1));
    _bottomMargin = max(0, min(bottom, rows - 1));
  }

  /// Resets the vertical scroll margins to the full height of the buffer.
  void resetVerticalMargins() => setVerticalMargins(0, rows - 1);

  /// Whether the cursor is currently within the defined vertical margins.
  bool isCursorInMargins() =>
      cursorRow >= _topMargin && cursorRow <= _bottomMargin;

  /// Save Cursor (DECSC)
  /// - https://terminalguide.namepad.de/seq/a_esc_a7/
  void saveCursor() {
    savedCursorRow = cursorRow;
    savedCursorCol = cursorCol;
    savedFormat = currentFormat;
    // TODO: implement charset
  }

  /// Restore Cursor (DECRC)
  /// - https://terminalguide.namepad.de/seq/a_esc_a8/
  void restoreCursor() {
    if (savedCursorRow != null) {
      cursorRow = savedCursorRow!;
    }
    if (savedCursorCol != null) {
      cursorCol = savedCursorCol!;
    }
    if (savedFormat != null) {
      currentFormat = savedFormat!;
    }
    // TODO: implement charset
  }

  /// Cursor Left (CUB)
  /// - https://terminalguide.namepad.de/seq/csi_cd/
  void cursorLeft(int amount) {
    if (amount == 0) amount = 1;
    cursorCol = max(0, cursorCol - amount);
  }

  /// Cursor Right (CUF)
  /// - https://terminalguide.namepad.de/seq/csi_cc/
  void cursorRight(int amount) {
    if (amount == 0) amount = 1;
    cursorCol = min(cols - 1, cursorCol + amount);
  }

  /// Cursor Up (CUU)
  /// - https://terminalguide.namepad.de/seq/csi_ca/
  void cursorUp(int amount) {
    if (amount == 0) amount = 1;
    if (isCursorInMargins()) {
      cursorRow = max(_topMargin, cursorRow - amount);
    } else {
      cursorRow = max(0, cursorRow - amount);
    }
  }

  /// Cursor Down (CUD)
  /// https://terminalguide.namepad.de/seq/csi_cb/
  void cursorDown(int amount) {
    if (amount == 0) amount = 1;
    if (isCursorInMargins()) {
      cursorRow = min(_bottomMargin, cursorRow + amount);
    } else {
      cursorRow = min(rows - 1, cursorRow + amount);
    }
  }
}
