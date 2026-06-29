import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Back Index (DECBI)
/// https://terminalguide.namepad.de/seq/a_esc_a6/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Back Index (DECBI)', () {
    test('moves cursor left by one column', () {
      controller.feed('abc'); // cursor at (0, 3)
      controller.feed('\x1b6');
      expectCursorAt(controller, 0, 2);
    });

    test('does not move cursor left of column 0', () {
      controller.feed('\x1b6'); // already at (0, 0)
      expectCursorAt(controller, 0, 0);

      controller.feed('\x1b6');
      expectCursorAt(controller, 0, 0);
    });

    test('does not affect row', () {
      controller.feed('abc\x0Aaaa'); // cursor at (1, 3)
      controller.feed('\x1b6');
      expectCursorAt(controller, 1, 5);
    });

    test('at column 0, scrolls screen right and keeps cursor at col 0', () {
      controller.feed('abc');
      controller.feed('\x1b[H');
      controller.feed('\x1b6');

      expectCursorAt(controller, 0, 0);
      expectCellAt(controller, 0, 0, ch: ' ');
      expectCellAt(controller, 0, 1, ch: 'a');
    });
  });
}
