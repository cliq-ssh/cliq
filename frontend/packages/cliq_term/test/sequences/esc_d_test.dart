import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Index (IND)
/// https://terminalguide.namepad.de/seq/a_esc_cd/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Index (IND)', () {
    test('moves cursor down one line without changing column', () {
      controller.feed('ab'); // cursor at (0, 2)
      controller.feed('\x1bD');
      TerminalTestUtils.expectCursorAt(controller, 1, 2);
    });

    test('at bottom of screen, scrolls up', () {
      // move to last row
      controller.feed('\x1b[${controller.rows};1H');
      controller.feed('abc');
      controller.feed('\x1bD');

      // cursor stays on last row
      TerminalTestUtils.expectCursorAt(controller, controller.rows - 1, 3);
      TerminalTestUtils.expectCellAt(
        controller,
        controller.rows - 2,
        0,
        ch: 'a',
      );
    });

    test('at bottom of scroll region, scrolls region only', () {
      controller.feed('\x1b[1;3r'); // set scroll region rows 1-3
      controller.feed('\x1b[3;1H');
      controller.feed('abc');
      controller.feed('\x1bD');

      // row 2 scrolled up, row 3 (bottom of region) cleared
      TerminalTestUtils.expectCellAt(controller, 1, 0, ch: 'a');
      TerminalTestUtils.expectCellAt(controller, 2, 0, ch: ' ');
    });

    test('outside scroll region, just moves down', () {
      controller.feed('\x1b[2;4r'); // scroll region rows 2-4
      controller.feed('\x1b[1;1H'); // cursor at row 1, outside region
      controller.feed('\x1bD');
      TerminalTestUtils.expectCursorAt(controller, 1, 0);
    });
  });
}
