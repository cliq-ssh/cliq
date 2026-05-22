import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Reverse Index (RI)
/// https://terminalguide.namepad.de/seq/a_esc_cm/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Reverse Index (RI)', () {
    test('moves cursor up one line without changing column', () {
      controller.feed('ab\x0Acd'); // cursor at (1, 4)
      controller.feed('\x1bM');
      TerminalTestUtils.expectCursorAt(controller, 0, 4);
    });

    test('at top of scroll region, scrolls down instead of moving up', () {
      controller.feed('\x1b[2;4r');
      controller.feed('\x1b[2;1H');
      controller.feed('abc');
      controller.feed('\x1bM');

      // content shifts down, top of region is now blank
      TerminalTestUtils.expectCellAt(controller, 1, 0, ch: ' ');
      // 'abc' moved to row below
      TerminalTestUtils.expectCellAt(controller, 2, 0, ch: 'a');
    });

    test('at top of screen (no scroll region), scrolls screen down', () {
      controller.feed('abc');
      controller.feed('\x0A');
      controller.feed('\x1b[1;1H');
      controller.feed('\x1bM');

      // row 0 should be blank, 'abc' pushed to row 1
      TerminalTestUtils.expectCellAt(controller, 0, 0, ch: ' ');
      TerminalTestUtils.expectCellAt(controller, 1, 0, ch: 'a');
    });

    test('outside scroll region, just moves up', () {
      controller.feed('\x1b[3;5r'); // scroll region rows 3-5
      controller.feed('\x1b[2;5H'); // cursor at row 1
      controller.feed('\x1bM');
      TerminalTestUtils.expectCursorAt(controller, 0, 4);
    });
  });
}
