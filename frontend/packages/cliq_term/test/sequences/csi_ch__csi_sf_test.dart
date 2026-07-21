import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Set Cursor Position (CUP)
/// https://terminalguide.namepad.de/seq/csi_ch/
/// https://terminalguide.namepad.de/seq/csi_sf/ (Alias)
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  for (final finalByte in ['H', 'f']) {
    group('Set Cursor Position (CSI $finalByte)', () {
      test('moves the cursor to the given row and column, 1-indexed', () {
        controller.feed('$kSeqEscape[5;10$finalByte');
        expectCursorAt(controller, 4, 9);
      });

      test(
        'defaults both row and column to 1 when no parameters are given',
        () {
          controller.feed('$kSeqEscape[3;3H'); // move away from origin first
          controller.feed('$kSeqEscape[$finalByte');
          expectCursorAt(controller, 0, 0);
        },
      );

      test('defaults the column to 1 when only the row is given', () {
        controller.feed('$kSeqEscape[7;7H');
        controller.feed('$kSeqEscape[4$finalByte');
        expectCursorAt(controller, 3, 0);
      });

      test(
        'clamps the row to the last row when it exceeds terminal height',
        () {
          controller.feed('$kSeqEscape[500;1$finalByte');
          expectCursorAt(controller, controller.rows - 1, 0);
        },
      );

      test(
        'clamps the column to the last column when it exceeds terminal width',
        () {
          controller.feed('$kSeqEscape[1;500$finalByte');
          expectCursorAt(controller, 0, controller.cols - 1);
        },
      );

      test('cancels a pending autowrap', () {
        controller.feed('$kSeqEscape[?7h'); // autowrap on
        controller.feed('a' * controller.cols); // arm pendingWrap
        controller.feed('$kSeqEscape[1;1$finalByte');
        controller.feed('x');
        // Should overwrite column 0 in place, not wrap to the next row.
        expect(controller.activeBuffer.getCell(0, 0).ch, 'x');
      });
    });
  }

  test('CUP (H) and HVP (f) are equivalent for the same parameters', () {
    controller.feed('$kSeqEscape[6;12H');
    final cupRow = controller.activeBuffer.cursorRow;
    final cupCol = controller.activeBuffer.cursorCol;

    controller.feed('$kSeqEscape[1;1H'); // reset
    controller.feed('$kSeqEscape[6;12f');

    expect(controller.activeBuffer.cursorRow, cupRow);
    expect(controller.activeBuffer.cursorCol, cupCol);
  });
}
