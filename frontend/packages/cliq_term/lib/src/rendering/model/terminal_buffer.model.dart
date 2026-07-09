import 'dart:math';

import 'package:cliq_term/cliq_term.dart';

import '../../state/charset.state.dart';
import '../../utils/selection_helper.dart';

class TerminalBufferRow {
  final List<Cell> cells;

  TerminalBufferRow(int cols)
    : cells = List.generate(cols, (_) => Cell.empty(), growable: false);

  void clear() {
    for (var i = 0; i < cells.length; i++) {
      cells[i] = Cell.empty();
    }
  }
}

class TerminalBuffer {
  static const int defaultMaxScrollbackLines = 2_000;
  static const int minMaxScrollbackLines = 0;
  static const int maxMaxScrollbackLines = 100_000;

  final int rows;
  final int cols;
  final int maxScrollbackLines;
  final bool isBackBuffer;

  final RingBuffer<TerminalBufferRow> _buffer;

  /// The current formatting options.
  FormattingOptions currentFormat = FormattingOptions();

  /// The current cursor row position.
  int cursorRow = 0;

  /// The current cursor column position.
  int cursorCol = 0;

  late Set<int> tabStops = Set.from(
    List.generate((cols ~/ 8), (i) => (i + 1) * 8).where((col) => col < cols),
  );

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

  /// Active charset state for this buffer.
  final CharsetState charset;

  TerminalBuffer({
    required this.rows,
    required this.cols,
    this.maxScrollbackLines = defaultMaxScrollbackLines,
    this.isBackBuffer = false,
    this.isLineFeedMode = false,
    CharsetState? charset,
  }) : _buffer = RingBuffer<TerminalBufferRow>(rows + maxScrollbackLines),
       _topMargin = 0,
       _bottomMargin = rows - 1,
       charset = charset ?? .new() {
    for (var i = 0; i < rows; i++) {
      _buffer.add(TerminalBufferRow(cols));
    }
  }

  int get length => _buffer.length;
  int get currentScrollback => _buffer.length - rows;

  TerminalBuffer resize({required int newRows, required int newCols}) {
    // Assert that the new dimensions are valid
    newRows = max(1, newRows);
    newCols = max(1, newCols);

    final newBuffer = TerminalBuffer(
      rows: newRows,
      cols: newCols,
      maxScrollbackLines: maxScrollbackLines,
      isBackBuffer: isBackBuffer,
      isLineFeedMode: isLineFeedMode,
      charset: CharsetState.copyFrom(charset),
    );

    newBuffer.isAutoWrapMode = isAutoWrapMode;
    newBuffer.tabStops = Set.from(tabStops.where((s) => s < newCols));

    // Preserve history and visible rows by copying rows from the old ring buffer
    // When shrinking, we try to discard trailing empty lines to avoid unnecessary scrollback
    final oldCurrentScrollback = currentScrollback;
    final absCursorRow = cursorRow + oldCurrentScrollback;
    newBuffer._buffer.clear();

    int effectiveOldLength = _buffer.length;
    final emptyFormat = FormattingOptions();
    while (effectiveOldLength > newRows) {
      final row = _buffer[effectiveOldLength - 1];
      bool isEmpty = true;
      for (final cell in row.cells) {
        if (cell.ch != ' ' || cell.fmt != emptyFormat) {
          isEmpty = false;
          break;
        }
      }
      if (isEmpty && (effectiveOldLength - 1) > absCursorRow) {
        effectiveOldLength--;
      } else {
        break;
      }
    }

    final minCols = min(cols, newCols);
    for (var i = 0; i < effectiveOldLength; i++) {
      final oldRow = _buffer[i];
      final newRow = TerminalBufferRow(newCols);
      for (var c = 0; c < minCols; c++) {
        newRow.cells[c] = Cell.clone(oldRow.cells[c]);
      }
      newBuffer._buffer.add(newRow);
    }

    // Ensure we have at least "newRows" in the buffer to satisfy currentScrollback calculations
    while (newBuffer.length < newRows) {
      newBuffer._buffer.add(TerminalBufferRow(newCols));
    }

    // Adjust cursor position relative to the content. If the screen grows, the visible
    // content shifts "up" in the viewport relative to the bottom, so the cursorRow
    // must be adjusted based on the change in currentScrollback
    final newCurrentScrollback = newBuffer.currentScrollback;
    newBuffer.cursorRow = (absCursorRow - newCurrentScrollback).clamp(
      0,
      newRows - 1,
    );
    newBuffer.cursorCol = cursorCol.clamp(0, newCols - 1);

    return newBuffer;
  }

  /// Index (IND)
  /// - https://terminalguide.namepad.de/seq/a_esc_cd/
  void index() {
    if (isCursorInMargins()) {
      if (cursorRow == _bottomMargin) {
        // Use pushEmptyLine for full-screen scrolls to preserve history
        if (_topMargin == 0 && _bottomMargin == rows - 1 && !isBackBuffer) {
          pushEmptyLine();
        } else {
          scrollUp(1);
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
        _buffer.prepend(TerminalBufferRow(cols));
        final topVisibleIdx = currentScrollback;
        _buffer[topVisibleIdx].clear();
      }
    } else {
      cursorUp(1);
    }
  }

  /// Next Line (NEL)
  /// - https://terminalguide.namepad.de/seq/a_esc_ce/
  void nextLine() {
    index();
    carriageReturn();
  }

  /// Horizontal Tab Set (HTS)
  /// - https://terminalguide.namepad.de/seq/a_esc_ch/
  void horizontalTabSet() {
    // col 0 is always an implicit start position, not a settable tab stop
    if (cursorCol > 0 && cursorCol < cols) {
      tabStops.add(cursorCol);
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
    final stops = tabStops.where((s) => s > cursorCol).toList()..sort();
    if (stops.isEmpty) {
      cursorCol = cols - 1;
    } else {
      cursorCol = stops.first;
    }
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
    final translated = charset.translate(cu);

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
      Cell(
        String.fromCharCode(translated),
        FormattingOptions.clone(currentFormat),
      ),
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
      _buffer.add(TerminalBufferRow(cols));
    }
    // reset cursor position
    cursorRow = 0;
    cursorCol = 0;
  }

  void pushEmptyLine() {
    _buffer.add(TerminalBufferRow(cols));
    cursorRow = rows - 1;
  }

  /// Forward Index (DECFI)
  /// - https://terminalguide.namepad.de/seq/a_esc_a9/
  void forwardIndex() {
    if (cursorCol < cols - 1) {
      cursorRight(1);
    } else {
      // at rightmost column, scroll region content left, cursor stays
      final visibleStart = currentScrollback;
      for (var r = _topMargin; r <= _bottomMargin; r++) {
        final row = _buffer[visibleStart + r];
        for (var c = 0; c < cols - 1; c++) {
          row.cells[c] = row.cells[c + 1];
        }
        row.cells[cols - 1] = Cell.empty();
      }
    }
  }

  /// Back Index (DECBI)
  /// - https://terminalguide.namepad.de/seq/a_esc_a6/
  void backIndex() {
    if (cursorCol > 0) {
      cursorLeft(1);
      return;
    }
    // at left margin, scroll screen right
    final visibleStart = currentScrollback;
    for (var r = 0; r < rows; r++) {
      final row = _buffer[visibleStart + r];
      for (var c = cols - 1; c > 0; c--) {
        row.cells[c] = row.cells[c - 1];
      }
      // blank the leftmost column
      row.cells[0] = Cell.empty();
    }
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
        _buffer[destIdx] = TerminalBufferRow(cols);
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
        _buffer[destIdx] = TerminalBufferRow(cols);
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
    savedFormat = FormattingOptions.clone(currentFormat);
    charset.save();
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
    charset.restore();
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

  /// Exports the visible screen as plain text.
  /// Each visible row is converted to text and trailing spaces are trimmed.
  /// This exports only the currently visible rows (not the full scrollback).
  String exportVisibleText() {
    final sb = StringBuffer();
    for (var r = 0; r < rows; r++) {
      // find last non-space cell to trim trailing spaces
      var lastNonSpace = -1;
      for (var c = 0; c < cols; c++) {
        final ch = getCell(r, c).ch;
        if (ch.trim().isNotEmpty) lastNonSpace = c;
      }

      if (lastNonSpace == -1) {
        // empty row
        sb.writeln();
        continue;
      }

      for (var c = 0; c <= lastNonSpace; c++) {
        sb.write(getCell(r, c).ch);
      }

      if (r < rows - 1) sb.writeln();
    }
    return sb.toString();
  }

  /// Exports a selection given by visible start/end coordinates.
  /// Coordinates are visible row/col indices (0..rows-1). The method will
  /// normalize start/end ordering and return the selected text with newlines
  /// between rows. Trailing whitespace in each row is trimmed.
  String exportSelection(int startRow, int startCol, int endRow, int endCol) {
    final bounds = SelectionHelper.normalize(
      startRow: startRow,
      startCol: startCol,
      endRow: endRow,
      endCol: endCol,
      maxRows: length,
      maxCols: cols,
    );

    final sb = StringBuffer();
    for (var r = bounds.startRow; r <= bounds.endRow; r++) {
      final rowSel = SelectionHelper.getRowSelection(
        row: r,
        bounds: bounds,
        maxCols: cols,
      );

      if (rowSel.isEmpty) continue;

      final rowSb = StringBuffer();
      for (var c = rowSel.start; c <= rowSel.end; c++) {
        rowSb.write(getAbsoluteCell(r, c).ch);
      }

      String rowText = rowSb.toString();

      // Only trim trailing whitespace if there's no non-whitespace text after the selection in this row.
      // This preserves intentional trailing spaces within a line while removing trailing spaces at the end of a line.
      bool hasTextAfterSelection = false;
      for (var c = rowSel.end + 1; c < cols; c++) {
        if (getAbsoluteCell(r, c).ch != ' ') {
          hasTextAfterSelection = true;
          break;
        }
      }

      if (!hasTextAfterSelection) {
        rowText = rowText.trimRight();
      }

      sb.write(rowText);
      if (r < bounds.endRow) sb.writeln();
    }
    return sb.toString();
  }
}
