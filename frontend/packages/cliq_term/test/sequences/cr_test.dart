import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Carriage Return (CR)
/// https://terminalguide.namepad.de/seq/a_c0-m/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Carriage Return (CR)', () {
    test('moves cursor to beginning of line', () {
      controller.feed('abc\x0D');
      TerminalTestUtils.expectCursorAt(controller, 0, 0);
    });

    test('does not move cursor vertically', () {
      controller.feed('a\x0Ab\x0Ac\x0D'); // 2x LFs -> row 2, then CR
      TerminalTestUtils.expectCursorAt(controller, 2, 0); // still row 2
    });

    test('does not erase characters on the line', () {
      controller.feed('abc\x0D');
      TerminalTestUtils.expectCellAt(controller, 0, 0, ch: 'a');
      TerminalTestUtils.expectCellAt(controller, 0, 1, ch: 'b');
      TerminalTestUtils.expectCellAt(controller, 0, 2, ch: 'c');
    });
  });
}

