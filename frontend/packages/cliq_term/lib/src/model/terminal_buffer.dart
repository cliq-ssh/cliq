import 'dart:math';

import '../../cliq_term.dart';

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
  final List<Row> _buffer;
  final bool isBackBuffer;
  final bool isLineFeedMode;

  /// The current formatting options.
  FormattingOptions currentFormat = FormattingOptions();

  /// The current cursor row position.
  int cursorRow = 0;

  /// The current cursor column position.
  int cursorCol = 0;

  /// The start index of the circular buffer.
  int _start = 0;

  int _topMargin;
  int _bottomMargin;

  int? savedCursorRow;
  int? savedCursorCol;
  FormattingOptions? savedFormat;

  TerminalBuffer({
    required this.rows,
    required this.cols,
    this.isBackBuffer = false,
    this.isLineFeedMode = false,
  }) : _buffer = List.generate(rows, (_) => Row(cols), growable: false),
       _topMargin = 0,
       _bottomMargin = rows - 1;

  int get length => _buffer.length;
  int _idxForRow(int row) => (_start + row) % _buffer.length;

  TerminalBuffer resize({required int newRows, required int newCols}) {
    final newBuffer = TerminalBuffer(rows: newRows, cols: newCols);
    final minRows = rows < newRows ? rows : newRows;
    final minCols = cols < newCols ? cols : newCols;

    for (var r = 0; r < minRows; r++) {
      for (var c = 0; c < minCols; c++) {
        newBuffer.setCell(r, c, getCell(r, c));
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
        scrollUp(1);
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

  Cell getCell(int row, int col) {
    final rowIdx = _idxForRow(row);
    return _buffer[rowIdx].cells[col];
  }

  void setCell(int row, int col, Cell cell) {
    final rowIdx = _idxForRow(row);
    _buffer[rowIdx].cells[col] = cell;
  }

  void setCellAtCursor(Cell cell) {
    setCell(cursorRow, cursorCol, cell);
  }

  /// Writes a single character at the current cursor position.
  void write(int cu) {
    if (cursorCol >= cols) {
      index();
      cursorCol = 0;
    }

    setCellAtCursor(
      Cell(String.fromCharCode(cu), FormattingOptions.clone(currentFormat)),
    );

    if (cursorCol < cols) {
      cursorCol++;
    }
  }

  void clear() {
    for (final row in _buffer) {
      row.clear();
    }
    // reset cursor position
    cursorRow = 0;
    cursorCol = 0;
  }

  void pushEmptyLine() {
    _start = (_start + 1) % _buffer.length;
    final rowIdx = _idxForRow(rows - 1);
    _buffer[rowIdx].clear();
  }

  /// Scroll Up (SU)
  /// - https://terminalguide.namepad.de/seq/csi_cs/
  void scrollUp(int amount) {
    if (amount == 0) amount = 1;

    for (var i = _topMargin; i <= _bottomMargin; i++) {
      if (i <= _bottomMargin - amount) {
        _buffer[i] = _buffer[i + amount];
      } else {
        _buffer[i] = Row(cols);
      }
    }
  }

  /// Scroll Down (SD)
  /// - https://terminalguide.namepad.de/seq/csi_ct_1param/
  void scrollDown(int amount) {
    // first param is always != 0, otherwise it would be Track Mouse (https://terminalguide.namepad.de/seq/csi_ct_5param/)
    if (amount == 0) return;
    for (var i = _bottomMargin; i >= _topMargin; i--) {
      if (i >= _topMargin + amount) {
        _buffer[i] = _buffer[i - amount];
      } else {
        _buffer[i] = Row(cols);
      }
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

  /// Sets the vertical scroll margins to the specified [top] and [bottom] rows.
  /// Both [top] and [bottom] must be within the range of the buffer's rows.
  void setVerticalScrollMargins(int top, int bottom) {
    _topMargin = max(0, min(top, rows - 1));
    _bottomMargin = max(0, min(bottom, rows - 1));
  }

  /// Resets the vertical scroll margins to the full height of the buffer.
  void resetVerticalMargins() => setVerticalScrollMargins(0, rows - 1);

  /// Whether the cursor is currently within the defined vertical margins.
  bool isCursorInMargins() =>
      cursorRow >= _topMargin && cursorRow <= _bottomMargin;

  /// Save Cursor (DECSC)
  /// - https://terminalguide.namepad.de/seq/a_esc_a7/
  void saveCursorPosition() {
    savedCursorRow = cursorRow;
    savedCursorCol = cursorCol;
    savedFormat = currentFormat;
    // TODO: implement charset
  }

  /// Restore Cursor (DECRC)
  /// - https://terminalguide.namepad.de/seq/a_esc_a8/
  void restoreCursorPosition() {
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
