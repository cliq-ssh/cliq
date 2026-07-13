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
      controller.feed('${kSeqEscape}D');
      expectCursorAt(controller, 1, 2);
    });

    test('at bottom of screen, scrolls up', () {
      // move to last row
      controller.feed('$kSeqEscape[${controller.rows};1H');
      controller.feed('abc');
      controller.feed('${kSeqEscape}D');

      // cursor stays on last row
      expectCursorAt(controller, controller.rows - 1, 3);
      expectCellAt(controller, controller.rows - 1, 0, ch: 'a');
    });

    test('at bottom of scroll region, scrolls region only', () {
      controller.feed('$kSeqEscape[1;3r'); // set scroll region rows 1-3
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('abc');
      controller.feed('${kSeqEscape}D');

      // row 2 scrolled up, row 3 (bottom of region) cleared
      expectCellAt(controller, 1, 0, ch: 'a');
      expectCellAt(controller, 2, 0, ch: ' ');
    });

    test('outside scroll region, just moves down', () {
      controller.feed('$kSeqEscape[2;4r'); // scroll region rows 2-4
      controller.feed('$kSeqEscape[1;1H'); // cursor at row 1, outside region
      controller.feed('${kSeqEscape}D');
      expectCursorAt(controller, 1, 0);
    });
  });
}
