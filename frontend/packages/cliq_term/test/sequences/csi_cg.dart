import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Alias: Cursor Horizontal Position Absolute
/// https://terminalguide.namepad.de/seq/csi_cg/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Alias: Cursor Horizontal Position Absolute', () {
    test('moves cursor to the given column, 1-indexed', () {
      controller.feed('abc'); // cursor at (0, 3)
      controller.feed('$kSeqEscape[1G');
      expectCursorAt(controller, 0, 0);
    });

    test('moves to an arbitrary column, keeping the row unchanged', () {
      controller.feed('$kSeqEscape[3;10H'); // row 2, col 9
      controller.feed('$kSeqEscape[14G');
      expectCursorAt(controller, 2, 13);
    });

    test('defaults to column 1 when no parameter is given', () {
      controller.feed('abc');
      controller.feed('$kSeqEscape[G');
      expectCursorAt(controller, 0, 0);
    });

    test('clamps to the last column when the value exceeds terminal width', () {
      controller.feed('$kSeqEscape[500G');
      expectCursorAt(controller, 0, controller.cols - 1);
    });

    test('does not affect the current row', () {
      controller.feed('$kSeqEscape[5;1H'); // row 4
      controller.feed('$kSeqEscape[20G');
      expect(controller.activeBuffer.cursorRow, 4);
    });
  });
}
