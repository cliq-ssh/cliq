import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/terminal_test_utils.dart';

/// Tests tracking mode handling (1000/1002/1003) + SGR (1006) encoding, and the
/// escape sequences emitted for click/release/motion/scroll.
void main() {
  String? sent;
  late TerminalController controller;

  setUp(() {
    sent = null;
    controller = TerminalTestUtils.createController(
      onInput: (data) => sent = data,
    );
  });

  group('Mouse tracking mode gating', () {
    test('no report is sent when tracking is disabled', () {
      controller.reportMouseEvent(row: 0, col: 0);
      expect(sent, isNull);
    });

    test('normal mode (1000) reports clicks but not motion', () {
      controller.feed('$kSeqEscape[?1000h');
      controller.reportMouseEvent(row: 0, col: 0);
      expect(sent, isNotNull);

      sent = null;
      controller.reportMouseEvent(row: 0, col: 0, isMotion: true);
      expect(sent, isNull);
    });

    test(
      'button-event mode (1002) reports motion only while a button is held',
      () {
        controller.feed('$kSeqEscape[?1002h');

        controller.reportMouseEvent(row: 0, col: 0, isMotion: true);
        expect(sent, isNull);

        controller.reportMouseEvent(row: 0, col: 0, button: 0);
        sent = null;
        controller.reportMouseEvent(row: 1, col: 1, isMotion: true);
        expect(sent, isNotNull);
      },
    );

    test('any-event mode (1003) reports motion even with no button held', () {
      controller.feed('$kSeqEscape[?1003h');
      controller.reportMouseEvent(row: 0, col: 0, isMotion: true);
      expect(sent, isNotNull);
    });
  });

  group('SGR (1006) encoding', () {
    test(
      'press is encoded as CSI < Cb ; Cx ; Cy M with 1-indexed coordinates',
      () {
        controller.feed('$kSeqEscape[?1000;1006h');
        controller.reportMouseEvent(row: 4, col: 9, button: 0);
        expect(sent, '$kSeqEscape[<0;10;5M');
      },
    );

    test('release is encoded with the same button and a trailing m', () {
      controller.feed('$kSeqEscape[?1000;1006h');
      controller.reportMouseEvent(row: 0, col: 0, button: 2, isRelease: true);
      expect(sent, '$kSeqEscape[<2;1;1m');
    });

    test('scroll up/down use button codes 64/65', () {
      controller.feed('$kSeqEscape[?1000;1006h');

      controller.reportMouseEvent(row: 0, col: 0, isScroll: true, button: 0);
      expect(sent, '$kSeqEscape[<64;1;1M');

      controller.reportMouseEvent(row: 0, col: 0, isScroll: true, button: 1);
      expect(sent, '$kSeqEscape[<65;1;1M');
    });

    test('modifier keys add to the button code', () {
      controller.feed('$kSeqEscape[?1000;1006h');
      controller.reportMouseEvent(row: 0, col: 0, button: 0, shift: true);
      expect(sent, '$kSeqEscape[<4;1;1M');
    });
  });

  group('Legacy X10 encoding (no 1006)', () {
    test('press is encoded as CSI M Cb Cx Cy with byte-offset coordinates', () {
      controller.feed('$kSeqEscape[?1000h');
      controller.reportMouseEvent(row: 0, col: 0, button: 0);
      expect(
        sent,
        '$kSeqEscape[M${String.fromCharCode(32)}'
        '${String.fromCharCode(33)}${String.fromCharCode(33)}',
      );
    });

    test('release always uses button code 3', () {
      controller.feed('$kSeqEscape[?1000h');
      controller.reportMouseEvent(row: 0, col: 0, button: 2, isRelease: true);
      expect(
        sent,
        '$kSeqEscape[M${String.fromCharCode(35)}'
        '${String.fromCharCode(33)}${String.fromCharCode(33)}',
      );
    });
  });
}
