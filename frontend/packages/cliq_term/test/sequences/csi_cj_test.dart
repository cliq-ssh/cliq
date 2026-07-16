import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Erase Display [Dispatch] (ED)
/// https://terminalguide.namepad.de/seq/csi_cj/
///
/// https://terminalguide.namepad.de/seq/csi_cj-0/
/// https://terminalguide.namepad.de/seq/csi_cj-1/
/// https://terminalguide.namepad.de/seq/csi_cj-2/
/// https://terminalguide.namepad.de/seq/csi_cj-3/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  /// Fills every visible cell with [ch] so we can tell what erase modes left behind.
  void fillScreen(String ch) {
    for (var r = 0; r < controller.rows; r++) {
      controller.feed('$kSeqEscape[${r + 1};1H');
      controller.feed(ch * controller.cols);
    }
  }

  group('Erase Display Below (CSI 0 J / CSI J)', () {
    test('erases from the cursor to the end of the screen', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3;5H');
      controller.feed('$kSeqEscape[0J');

      // before the cursor on the cursor's row: untouched
      expect(controller.activeBuffer.getCell(2, 3).ch, 'a');
      // at and after the cursor on the cursor's row: erased
      expect(controller.activeBuffer.getCell(2, 4).ch, ' ');
      expect(controller.activeBuffer.getCell(2, controller.cols - 1).ch, ' ');
      // rows below the cursor: erased
      expect(controller.activeBuffer.getCell(3, 0).ch, ' ');
      // rows above the cursor: untouched
      expect(controller.activeBuffer.getCell(1, 0).ch, 'a');
    });

    test('defaults to mode 0 when no parameter is given', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3;5H');
      controller.feed('$kSeqEscape[J');

      expect(controller.activeBuffer.getCell(2, 4).ch, ' ');
      expect(controller.activeBuffer.getCell(1, 0).ch, 'a');
    });

    test('does not affect cursor position', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3;5H');
      controller.feed('$kSeqEscape[0J');
      expectCursorAt(controller, 2, 4);
    });
  });

  group('Erase Display Above (CSI 1 J)', () {
    test('erases from the start of the screen to the cursor', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3;5H');
      controller.feed('$kSeqEscape[1J');

      // rows above the cursor: erased
      expect(controller.activeBuffer.getCell(0, 0).ch, ' ');
      // on the cursor's row, up to and including the cursor: erased
      expect(controller.activeBuffer.getCell(2, 0).ch, ' ');
      expect(controller.activeBuffer.getCell(2, 4).ch, ' ');
      // on the cursor's row, after the cursor: untouched
      expect(controller.activeBuffer.getCell(2, 5).ch, 'a');
      // rows below the cursor: untouched
      expect(controller.activeBuffer.getCell(3, 0).ch, 'a');
    });

    test('does not affect cursor position', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3;5H');
      controller.feed('$kSeqEscape[1J');
      expectCursorAt(controller, 2, 4);
    });
  });

  group('Erase Display Complete (CSI 2 J)', () {
    test('erases the entire visible screen', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[2J');

      for (var r = 0; r < controller.rows; r++) {
        for (var c = 0; c < controller.cols; c++) {
          expect(controller.activeBuffer.getCell(r, c).ch, ' ');
        }
      }
    });

    test('resets cursor position to the top-left', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3;5H');
      controller.feed('$kSeqEscape[2J');
      expectCursorAt(controller, 0, 0);
    });
  });

  group('Erase Display Scroll-back (CSI 3 J)', () {
    test('clears scrollback history but keeps the visible screen', () {
      for (var i = 0; i < controller.rows + 10; i++) {
        controller.feed('line $i\r\n');
      }

      expect(controller.activeBuffer.currentScrollback, greaterThan(0));

      final visibleBefore = controller.activeBuffer.exportVisibleText();

      controller.feed('$kSeqEscape[3J');

      expect(controller.activeBuffer.currentScrollback, 0);
      expect(controller.activeBuffer.exportVisibleText(), visibleBefore);
    });

    test('does nothing when there is no scrollback', () {
      expect(controller.activeBuffer.currentScrollback, 0);
      expect(() => controller.feed('$kSeqEscape[3J'), returnsNormally);
      expect(controller.activeBuffer.currentScrollback, 0);
    });

    test('does not affect cursor position', () {
      for (var i = 0; i < controller.rows + 10; i++) {
        controller.feed('line $i\r\n');
      }
      controller.feed('$kSeqEscape[5;5H');
      controller.feed('$kSeqEscape[3J');
      expectCursorAt(controller, 4, 4);
    });

    test('does not erase the visible screen content, only scrollback', () {
      fillScreen('a');
      controller.feed('$kSeqEscape[3J');
      expect(controller.activeBuffer.getCell(0, 0).ch, 'a');
    });
  });

  test('unhandled ED mode is ignored without crashing', () {
    expect(() => controller.feed('$kSeqEscape[9J'), returnsNormally);
  });
}
