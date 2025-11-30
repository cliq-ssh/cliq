import '../../cliq_term.dart';

class TerminalBuffer {
  final int rows;
  final int cols;
  final List<List<Cell>> _buffer;

  final int history;
  int _start = 0;

  TerminalBuffer(this.rows, this.cols, {this.history = 200})
      : _buffer = List.generate(
    rows + history,
        (_) => List.generate(cols, (_) => Cell.empty()),
    growable: false,
  );

  int _idxForRow(int row) => (_start + row) % _buffer.length;

  TerminalBuffer resize(int newRows, int newCols) {
    final newBuffer = TerminalBuffer(newRows, newCols, history: history);
    final minRows = rows < newRows ? rows : newRows;
    final minCols = cols < newCols ? cols : newCols;

    for (var r = 0; r < minRows; r++) {
      for (var c = 0; c < minCols; c++) {
        newBuffer.setCell(r, c, getCell(r, c));
      }
    }

    return newBuffer;
  }

  Cell getCell(int row, int col) => _buffer[_idxForRow(row)][col];
  void setCell(int row, int col, Cell cell) => _buffer[_idxForRow(row)][col] = cell;

  void pushEmptyLine() {
    _start = (_start + 1) % _buffer.length;
    final bottomIdx = _idxForRow(rows - 1);
    for (var c = 0; c < cols; c++) {
      _buffer[bottomIdx][c] = Cell.empty();
    }
  }

  void clear() {
    for (var i = 0; i < _buffer.length; i++) {
      for (var j = 0; j < cols; j++) {
        _buffer[i][j] = Cell.empty();
      }
    }
    _start = 0;
  }
}
