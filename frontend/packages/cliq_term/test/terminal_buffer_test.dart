import 'package:cliq_term/src/rendering/model/terminal_buffer.dart';
import 'package:test/test.dart';
import 'package:cliq_term/cliq_term.dart';

void main() {
  group('TerminalBuffer basic operations', () {
    test('init: all cells empty', () {
      final buf = TerminalBuffer(rows: 3, cols: 5);

      _expectBufferEquals([
        [' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' '],
      ], buf);
    });

    test('set/get cell', () {
      final buf = TerminalBuffer(rows: 2, cols: 3);

      final a = Cell('A', .new());
      final b = Cell('B', .new());

      buf.setCell(0, 0, a);
      buf.setCell(1, 2, b);

      _expectBufferEquals([
        ['A', ' ', ' '],
        [' ', ' ', 'B'],
      ], buf);
    });

    test('pushEmptyLine shifts visible rows and clears bottom', () {
      final buf = TerminalBuffer(rows: 3, cols: 2);

      buf.setCell(0, 0, Cell('0', .new()));
      buf.setCell(1, 0, Cell('1', .new()));
      buf.setCell(2, 0, Cell('2', .new()));

      // push one empty line, visible rows should shift up
      buf.pushEmptyLine();

      _expectBufferEquals([
        ['1', ' '],
        ['2', ' '],
        [' ', ' '],
      ], buf);
    });

    test('write lines (autowrap)', () {
      final buf = TerminalBuffer(rows: 3, cols: 3);
      buf.isAutoWrapMode = true;

      buf.printString('ABCDEFGHI');

      _expectBufferEquals([
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ], buf);
    });

    test('write lines (no autowrap)', () {
      final buf = TerminalBuffer(rows: 3, cols: 3);
      buf.isAutoWrapMode = false;

      buf.printString('ABCDEFGHI');

      _expectBufferEquals([
        ['A', 'B', 'I'],
        [' ', ' ', ' '],
        [' ', ' ', ' '],
      ], buf);
    });

    test('clear resets buffer', () {
      final buf = TerminalBuffer(rows: 2, cols: 2);

      buf.setCell(1, 1, Cell('X', .new()));

      _expectBufferEquals([
        [' ', ' '],
        [' ', 'X'],
      ], buf);

      buf.pushEmptyLine();
      buf.clear();

      _expectBufferEquals([
        [' ', ' '],
        [' ', ' '],
      ], buf);
    });
  });

  group('TerminalBuffer resizing', () {
    test('resize preserves top-left region when shrinking', () {
      final buf = TerminalBuffer(rows: 4, cols: 5);

      buf.setCell(0, 0, Cell('A', .new()));
      buf.setCell(1, 1, Cell('B', .new()));

      _expectBufferEquals([
        ['A', ' ', ' ', ' ', ' '],
        [' ', 'B', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' '],
      ], buf);

      final resized = buf.resize(newRows: 2, newCols: 3);
      _expectBufferEquals([
        ['A', ' ', ' '],
        [' ', 'B', ' '],
      ], resized);
    });

    test('resize enlarges with preserved content', () {
      final buf = TerminalBuffer(rows: 2, cols: 2);

      buf.setCell(0, 0, Cell('X', .new()));
      buf.setCell(1, 1, Cell('Y', .new()));

      _expectBufferEquals([
        ['X', ' '],
        [' ', 'Y'],
      ], buf);

      final resized = buf.resize(newRows: 4, newCols: 5);
      _expectBufferEquals([
        ['X', ' ', ' ', ' ', ' '],
        [' ', 'Y', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' '],
      ], resized);
    });
  });
}

void _expectBufferEquals(List<List<String>> expected, TerminalBuffer buf) {
  // check size
  expect(buf.rows, equals(expected.length));
  expect(buf.cols, equals(expected[0].length));

  // check cell contents
  List<(int, int)> mismatches = [];
  for (var r = 0; r < expected.length; r++) {
    for (var c = 0; c < expected[r].length; c++) {
      if (buf.getCell(r, c).ch != expected[r][c]) {
        mismatches.add((r, c));
      }
    }
  }

  if (mismatches.isNotEmpty) {
    final bufferStr = StringBuffer();
    for (var r = 0; r < buf.rows; r++) {
      for (var c = 0; c < buf.cols; c++) {
        bufferStr.write('[${buf.getCell(r, c).ch}]');
      }
      bufferStr.writeln();
    }

    fail(
      'Buffer contents do not match!\n'
      '- Mismatches at: ${mismatches.map((e) => '[${e.$1}, ${e.$2}]').join(', ')}\n'
      '- Expected:\n${expected.map((row) => row.map((s) => '[$s]').join()).join('\n')}\n'
      '- Actual:\n$bufferStr',
    );
  }
}
