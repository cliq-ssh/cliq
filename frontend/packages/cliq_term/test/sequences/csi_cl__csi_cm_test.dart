import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Insert Line (IL) + Delete Line (DL)
/// https://terminalguide.namepad.de/seq/csi_cl/
/// https://terminalguide.namepad.de/seq/csi_cm/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  void labelRows() {
    for (var r = 0; r < controller.rows; r++) {
      controller.feed('$kSeqEscape[${r + 1};1H');
      controller.feed('row$r');
    }
  }

  String textOfRow(int row) {
    final buf = StringBuffer();
    for (var c = 0; c < 6; c++) {
      buf.write(controller.activeBuffer.getCell(row, c).ch);
    }
    return buf.toString().trimRight();
  }

  group('Insert Line (CSI L)', () {
    test(
      'inserts a blank line at the cursor row, shifting lines below down',
      () {
        labelRows();
        controller.feed('$kSeqEscape[3;1H');
        controller.feed('$kSeqEscape[L');
        expect(textOfRow(2), isEmpty);
        expect(textOfRow(3), 'row2');
      },
    );

    test(
      'the bottom-most line is discarded and replaced by the line above it',
      () {
        labelRows();
        final lastRow = controller.rows - 1;
        controller.feed('$kSeqEscape[3;1H');
        controller.feed('$kSeqEscape[L');
        expect(textOfRow(lastRow), 'row${lastRow - 1}');
      },
    );

    test('defaults to inserting 1 line when no parameter is given', () {
      labelRows();
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('$kSeqEscape[L');
      expect(textOfRow(3), 'row2');
    });

    test('respects an explicit count', () {
      labelRows();
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('$kSeqEscape[2L');
      expect(textOfRow(2), isEmpty);
      expect(textOfRow(3), isEmpty);
      expect(textOfRow(4), 'row2');
    });

    test('does nothing when the cursor is outside the scroll margins', () {
      controller.feed('$kSeqEscape[3;10r');
      labelRows();
      controller.feed('$kSeqEscape[1;1H');
      controller.feed('$kSeqEscape[L');
      expect(textOfRow(0), 'row0');
    });
  });

  group('Delete Line (CSI M)', () {
    test('deletes the cursor row, shifting lines below up', () {
      labelRows();
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('$kSeqEscape[M');
      expect(textOfRow(2), 'row3');
      expect(textOfRow(3), 'row4');
    });

    test('blank lines appear at the bottom margin', () {
      labelRows();
      final lastRow = controller.rows - 1;
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('$kSeqEscape[M');
      expect(textOfRow(lastRow), isEmpty);
    });

    test('defaults to deleting 1 line when no parameter is given', () {
      labelRows();
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('$kSeqEscape[M');
      expect(textOfRow(2), 'row3');
    });

    test('respects an explicit count', () {
      labelRows();
      controller.feed('$kSeqEscape[3;1H');
      controller.feed('$kSeqEscape[2M');
      expect(textOfRow(2), 'row4');
    });

    test('does nothing when the cursor is outside the scroll margins', () {
      controller.feed('$kSeqEscape[3;10r');
      labelRows();
      controller.feed('$kSeqEscape[1;1H');
      controller.feed('$kSeqEscape[M');
      expect(textOfRow(0), 'row0');
    });
  });
}
