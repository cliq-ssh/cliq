import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Horizontal Tab Set (HTS)
/// https://terminalguide.namepad.de/seq/a_esc_ch/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Horizontal Tab Set (HTS)', () {
    test('marks current column as a tab stop', () {
      controller.feed('aaaa'); // cursor at (0, 4)
      controller.feed('${kSeqEscape}H');
      controller.feed('\x0D');
      controller.feed(kSeqTab);
      expectCursorAt(controller, 0, 4);
    });

    test('custom tab stop takes priority over default', () {
      controller.feed('aa'); // cursor at (0, 2)
      controller.feed('${kSeqEscape}H');
      controller.feed('\x0D');
      // should land at col 2, not default col 8
      controller.feed(kSeqTab);
      expectCursorAt(controller, 0, 2);
    });

    test('multiple custom tab stops work in sequence', () {
      controller.feed('aa');
      controller.feed('${kSeqEscape}H');
      controller.feed('aaa');
      controller.feed('${kSeqEscape}H');
      controller.feed('\x0D');
      controller.feed(kSeqTab);
      expectCursorAt(controller, 0, 2);
      controller.feed(kSeqTab);
      expectCursorAt(controller, 0, 5);
    });
  });
}
