import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Scroll Up (SU) + Scroll Down (SD)
/// https://terminalguide.namepad.de/seq/csi_cs/
/// https://terminalguide.namepad.de/seq/csi_ct_1param/
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

  group('Scroll Up (CSI S)', () {
    test('shifts the whole scroll region content up by one line', () {
      labelRows();
      controller.feed('$kSeqEscape[S');
      expect(textOfRow(0), 'row1');
      expect(textOfRow(controller.rows - 1), isEmpty);
    });

    test('respects an explicit count', () {
      labelRows();
      controller.feed('$kSeqEscape[3S');
      expect(textOfRow(0), 'row3');
    });

    test('is confined to the active scroll region', () {
      controller.feed('$kSeqEscape[3;10r');
      labelRows();
      controller.feed('$kSeqEscape[S');
      expect(textOfRow(0), 'row0');
      expect(textOfRow(2), 'row3');
    });
  });

  group('Scroll Down (CSI T)', () {
    test('shifts the whole scroll region content down by one line', () {
      labelRows();
      controller.feed('$kSeqEscape[T');
      expect(textOfRow(0), isEmpty);
      expect(textOfRow(1), 'row0');
    });

    test('respects an explicit count', () {
      labelRows();
      controller.feed('$kSeqEscape[3T');
      expect(textOfRow(3), 'row0');
    });

    test('is confined to the active scroll region', () {
      controller.feed('$kSeqEscape[3;10r');
      labelRows();
      controller.feed('$kSeqEscape[T');
      expect(textOfRow(0), 'row0');
      expect(textOfRow(3), 'row2');
    });
  });
}
