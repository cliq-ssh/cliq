import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Insert Blanks (ICH)
/// https://terminalguide.namepad.de/seq/csi_x40_at/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Insert Blanks (ICH)', () {
    test(
      'inserts a blank at the cursor, shifting the rest of the line right',
      () {
        controller.feed('hello');
        controller.feed(
          '$kSeqEscape[3G',
        ); // move to column 2 (0-indexed), i.e. between 'e' and 'l'
        controller.feed('$kSeqEscape[1@');

        expect(controller.activeBuffer.getCell(0, 0).ch, 'h');
        expect(controller.activeBuffer.getCell(0, 1).ch, 'e');
        expect(controller.activeBuffer.getCell(0, 2).ch, ' ');
        expect(controller.activeBuffer.getCell(0, 3).ch, 'l');
        expect(controller.activeBuffer.getCell(0, 4).ch, 'l');
        expect(controller.activeBuffer.getCell(0, 5).ch, 'o');
      },
    );

    test('defaults to inserting 1 character when no parameter is given', () {
      controller.feed('abc');
      controller.feed('$kSeqEscape[1G');
      controller.feed('$kSeqEscape[@');
      expect(controller.activeBuffer.getCell(0, 0).ch, ' ');
      expect(controller.activeBuffer.getCell(0, 1).ch, 'a');
    });

    test('respects an explicit count', () {
      controller.feed('abcde');
      controller.feed('$kSeqEscape[1G');
      controller.feed('$kSeqEscape[2@');
      expect(controller.activeBuffer.getCell(0, 0).ch, ' ');
      expect(controller.activeBuffer.getCell(0, 1).ch, ' ');
      expect(controller.activeBuffer.getCell(0, 2).ch, 'a');
    });

    test('characters shifted past the last column are discarded', () {
      final cols = controller.cols;
      controller.feed('a' * (cols - 1));
      controller.feed('Z'); // distinct marker in the last column
      controller.feed('$kSeqEscape[1G');
      controller.feed('$kSeqEscape[1@');
      expect(controller.activeBuffer.getCell(0, cols - 1).ch, isNot('Z'));
    });

    test('the cursor position does not change', () {
      controller.feed('abc');
      controller.feed('$kSeqEscape[2G');
      controller.feed('$kSeqEscape[1@');
      expectCursorAt(controller, 0, 1);
    });

    test('does nothing when the cursor is outside the scroll margins', () {
      controller.feed('$kSeqEscape[3;10r');
      controller.feed('abc');
      controller.feed('$kSeqEscape[1;1H');
      controller.feed('$kSeqEscape[1@');
      expect(controller.activeBuffer.getCell(0, 0).ch, 'a');
    });

    test(
      'inserted blanks are colored with the current SGR state, not reset to default',
      () {
        controller.feed('$kSeqEscape[41m'); // red background
        controller.feed('abc');
        controller.feed('$kSeqEscape[1G');
        controller.feed('$kSeqEscape[1@');

        final insertedCell = controller.activeBuffer.getCell(0, 0);
        expect(insertedCell.ch, ' ');
        expect(insertedCell.fmt.bgColor, isNotNull);
      },
    );

    test('clears a pending wrap without wrapping', () {
      controller.feed('$kSeqEscape[?7h'); // autowrap on
      controller.feed('a' * controller.cols); // arm pendingWrap
      controller.feed('$kSeqEscape[1@');

      // If pendingWrap were still armed, the next printed char would wrap
      // to the next row instead of landing back at the last column.
      controller.feed('$kSeqEscape[1;${controller.cols}H');
      controller.feed('z');
      expect(controller.activeBuffer.getCell(0, controller.cols - 1).ch, 'z');
    });
  });
}
