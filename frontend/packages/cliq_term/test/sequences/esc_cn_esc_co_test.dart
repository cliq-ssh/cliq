import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Single Shift 2 (SS2) / Single Shift 3 (SS3)
/// https://terminalguide.namepad.de/seq/a_esc_cn/
/// https://terminalguide.namepad.de/seq/a_esc_co/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Single Shift 2 (SS2) / Single Shift 3 (SS3)', () {
    test('SS2 applies G2 charset for only the next character', () {
      controller.feed('$kSeqEscape*0'); // DEC graphics into G2
      controller.feed('${kSeqEscape}N'); // SS2
      controller.feed('\x6a');
      controller.feed('\x6a');

      // first 'j' should be from G2 DEC graphics, second 'j' should be normal ASCII
      expectCellAt(controller, 0, 0, ch: String.fromCharCode(0x2518));
      expectCellAt(controller, 0, 1, ch: 'j');
    });

    test('SS3 applies G3 charset for only the next character', () {
      controller.feed('$kSeqEscape+0'); // DEC graphics into G3
      controller.feed('${kSeqEscape}O'); // SS3
      controller.feed('\x6a');
      controller.feed('\x6a');

      // first 'j' should be from G3 DEC graphics, second 'j' should be normal ASCII
      expectCellAt(controller, 0, 0, ch: String.fromCharCode(0x2518));
      expectCellAt(controller, 0, 1, ch: 'j');
    });

    test('SS2/SS3 does not affect current GL charset', () {
      controller.feed('$kSeqEscape(0'); // DEC graphics into G0
      controller.feed('$kSeqEscape*B'); // ASCI into G2
      controller.feed('${kSeqEscape}N'); // SS2, use G2 for next char
      controller.feed('\x6a');
      controller.feed('\x6a');

      expectCellAt(controller, 0, 0, ch: 'j');
      expectCellAt(controller, 0, 1, ch: String.fromCharCode(0x2518));
    });

    test('SS3 does not interfere with function key prefix ESC O', () {
      // ESC O followed by a CSI final byte should still work as F1-F4
      // This test just ensures 'a' after SS3 no-op prints correctly
      controller.feed('a${kSeqEscape}Ob');
      expectCellAt(controller, 0, 0, ch: 'a');
      expectCellAt(controller, 0, 1, ch: 'b');
    });
  });
}
