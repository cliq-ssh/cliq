import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Forward Index (DECFI)
/// https://terminalguide.namepad.de/seq/a_esc_a9/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Forward Index (DECFI)', () {
    test('moves cursor right by one column', () {
      controller.feed('abc'); // cursor at (0, 3)
      controller.feed('\x1b9');
      TerminalTestUtils.expectCursorAt(controller, 0, 4);
    });

    test('at rightmost column, scrolls content left', () {
      controller.feed('abcde');
      // manually position cursor at last col
      controller.setCursorPosition(0, controller.cols - 1);
      controller.feed('\x1b9');

      TerminalTestUtils.expectCursorAt(controller, 0, controller.cols - 1);
      TerminalTestUtils.expectCellAt(controller, 0, 0, ch: 'b');
    });

    test('does not change row', () {
      controller.feed('ab\x0A'); // cursor at (1, 2) after LF
      controller.feed('\x1b9');
      TerminalTestUtils.expectCursorAt(controller, 1, 3);
    });
  });
}
