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
      controller.feed('${kSeqEscape}M');
      expectCursorAt(controller, 0, 4);
    });

    test('at top of scroll region, scrolls down instead of moving up', () {
      controller.feed('$kSeqEscape[2;4r');
      controller.feed('$kSeqEscape[2;1H');
      controller.feed('abc');
      controller.feed('${kSeqEscape}M');

      // content shifts down, top of region is now blank
      expectCellAt(controller, 1, 0, ch: ' ');
      // 'abc' moved to row below
      expectCellAt(controller, 2, 0, ch: 'a');
    });

    test('at top of screen (no scroll region), scrolls screen down', () {
      controller.feed('abc');
      controller.feed('\x0A');
      controller.feed('$kSeqEscape[1;1H');
      controller.feed('${kSeqEscape}M');

      // row 0 should be blank, 'abc' pushed to row 1
      expectCellAt(controller, 0, 0, ch: ' ');
      expectCellAt(controller, 1, 0, ch: 'a');
    });

    test('outside scroll region, just moves up', () {
      controller.feed('$kSeqEscape[3;5r'); // scroll region rows 3-5
      controller.feed('$kSeqEscape[2;5H'); // cursor at row 1
      controller.feed('${kSeqEscape}M');
      expectCursorAt(controller, 0, 4);
    });
  });
}
