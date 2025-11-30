import '../../cliq_term.dart';

class TerminalBuffer {
  final int rows;
  final int cols;
  final List<List<Cell>> _buffer;

  TerminalBuffer(this.cols, this.rows)
    : _buffer = List.generate(
        rows,
        (_) => List.generate(cols, (_) => Cell.empty()),
        growable: false,
      );

  TerminalBuffer resize(int newRows, int newCols) {
    final newBuffer = TerminalBuffer(newCols, newRows);
    final minRows = rows < newRows ? rows : newRows;
    final minCols = cols < newCols ? cols : newCols;

    for (var r = 0; r < minRows; r++) {
      for (var c = 0; c < minCols; c++) {
        newBuffer.setCell(r, c, getCell(r, c));
      }
    }

    return newBuffer;
  }

  Cell getCell(int row, int col) => _buffer[row][col];
  void setCell(int row, int col, Cell cell) => _buffer[row][col] = cell;

  void clear() {
    for (var row in _buffer) {
      for (var i = 0; i < row.length; i++) {
        row[i] = Cell.empty();
      }
    }
  }
}
