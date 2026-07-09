import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Next Line (NEL)
/// https://terminalguide.namepad.de/seq/a_esc_ce/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Next Line (NEL)', () {
    test('moves cursor to beginning of next line', () {
      controller.feed('abc'); // cursor at (0, 3)
      controller.feed('\x1bE');
      expectCursorAt(controller, 1, 0);
    });

    test('always resets column to 0 regardless of current column', () {
      controller.feed('abcde'); // cursor at (0, 5)
      controller.feed('\x1bE');
      expectCursorAt(controller, 1, 0);
    });

    test('scrolls screen up and resets column when at bottom line', () {
      controller.feed('\x1b[${controller.rows};1H'); // move to last row
      controller.feed('abc');
      controller.feed('\x1bE');

      expectCursorAt(controller, controller.rows - 1, 0);
      expectCellAt(controller, controller.rows - 1, 0, ch: 'a');
    });
  });
}
