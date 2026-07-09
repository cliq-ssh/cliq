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

  group('TerminalBuffer exportSelection', () {
    test('exportSelection single line, trims trailing spaces', () {
      final buf = TerminalBuffer(rows: 2, cols: 10);
      buf.printString('hello     '); // 'hello' followed by 5 spaces

      // Select 'hello     ' (cols 0 to 9)
      final selection = buf.exportSelection(0, 0, 0, 9);
      expect(selection, equals('hello'));
    });

    test('exportSelection single line, preserves internal spaces', () {
      final buf = TerminalBuffer(rows: 2, cols: 10);
      buf.printString('a  b     '); // 'a', 2 spaces, 'b', 5 spaces

      // Select 'a  b     ' (cols 0 to 9)
      final selection = buf.exportSelection(0, 0, 0, 9);
      expect(selection, equals('a  b'));
    });

    test('exportSelection multi-line flow selection', () {
      final buf = TerminalBuffer(rows: 3, cols: 10);
      buf.printString('line 1');
      buf.setCursorPosition(1, 0);
      buf.printString('line 2');

      // Row 0: "line 1    "
      // Row 1: "line 2    "

      // Select from row 0, col 5 ('1') to row 1, col 5 ('2')
      final selection = buf.exportSelection(0, 5, 1, 5);
      expect(selection, equals('1\nline 2'));
    });

    test(
      'exportSelection multi-line, preserves trailing space if text follows in same row',
      () {
        final buf = TerminalBuffer(rows: 3, cols: 10);
        buf.printString('A B');
        // Row 0: "A B       "

        // Select from row 0 col 0 to row 0 col 1.
        // Text after col 1 is 'B' at col 2.
        final selection = buf.exportSelection(0, 0, 0, 1);
        expect(selection, equals('A '));
      },
    );

    test('exportSelection multi-line, trims trailing spaces at end of row', () {
      final buf = TerminalBuffer(rows: 3, cols: 10);
      buf.printString('row0');
      buf.setCursorPosition(1, 0);
      buf.printString('row1');

      // Select from 0,0 to 1,9
      final selection = buf.exportSelection(0, 0, 1, 9);
      expect(selection, equals('row0\nrow1'));
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
