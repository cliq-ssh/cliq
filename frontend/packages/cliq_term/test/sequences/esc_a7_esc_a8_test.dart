import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Save Cursor (DECSC) + Restore Cursor (DECRC)
/// https://terminalguide.namepad.de/seq/a_esc_a7/
/// https://terminalguide.namepad.de/seq/a_esc_a8/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Save Cursor (DECSC) + Restore Cursor (DECRC)', () {
    test('saves and restores cursor position', () {
      controller.feed('abc'); // cursor at (0, 3)
      controller.feed('${kSeqEscape}7');

      // move to (4, 9)
      controller.feed('$kSeqEscape[5;10H');
      expectCursorAt(controller, 4, 9);

      // restore
      controller.feed('${kSeqEscape}8');
      expectCursorAt(controller, 0, 3);
    });

    test('saves and restores formatting', () {
      controller.feed('$kSeqEscape[1m'); // bold on
      controller.feed('${kSeqEscape}7');

      // reset formatting
      controller.feed('$kSeqEscape[0m');
      controller.feed('${kSeqEscape}8');

      // print a char and verify it's bold
      controller.feed('a');
      final cell = controller.activeBuffer.getCell(0, 0);
      expect(cell.fmt.bold, isTrue);
    });

    test('restore without prior save does not crash', () {
      expect(() => controller.feed('${kSeqEscape}8'), returnsNormally);
    });

    test('save is per-buffer (main and alternate are distinct)', () {
      controller.feed('abc'); // cursor at (0, 3)

      // save on main
      controller.feed('${kSeqEscape}7');

      // switch to alt buffer
      controller.feed('$kSeqEscape[?1049h');

      controller.feed('${kSeqEscape}7');
      controller.feed('$kSeqEscape[3;3H');

      // restore on alt should go to (3, 3)
      controller.feed('${kSeqEscape}8');
      expectCursorAt(controller, 0, 0);

      // restore on main should still go to (0, 3)
      controller.feed('$kSeqEscape[?1049l');
      expectCursorAt(controller, 0, 3);
    });
  });
}
