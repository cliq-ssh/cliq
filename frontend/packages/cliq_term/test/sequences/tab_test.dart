import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Horizontal Tab (TAB)
/// https://terminalguide.namepad.de/seq/a_c0-i/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Horizontal Tab (TAB)', () {
    test('moves cursor to next tab stop', () {
      // "In the reset state of the terminal tab stops are set on each 8th column, starting in column 1."
      controller.feed('a\x09b');
      TerminalTestUtils.expectCellAt(controller, 0, 0, ch: 'a');
      TerminalTestUtils.expectCellAt(controller, 0, 8, ch: 'b');
    });

    test('clamps at last column', () {
      // feed enough tabs to exceed terminal width
      controller.feed('\x09' * 20);
      expect(controller.activeBuffer.cursorCol, equals(controller.cols - 1));
    });
  });
}

