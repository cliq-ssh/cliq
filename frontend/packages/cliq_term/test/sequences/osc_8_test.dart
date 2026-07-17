import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Hyperlink (OSC 8)
/// https://terminalguide.namepad.de/seq/osc-8/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Hyperlink (OSC 8)', () {
    test('printed text after OSC 8 carries the URL', () {
      controller.feed(
        '$kSeqEscape]8;;https://example.com\x07link$kSeqEscape]8;;\x07',
      );
      expect(
        controller.activeBuffer.getCell(0, 0).fmt.hyperlink,
        'https://example.com',
      );
      expect(
        controller.activeBuffer.getCell(0, 3).fmt.hyperlink,
        'https://example.com',
      );
    });

    test('an empty URI closes the link', () {
      controller.feed(
        '$kSeqEscape]8;;https://example.com\x07a$kSeqEscape]8;;\x07b',
      );
      expect(
        controller.activeBuffer.getCell(0, 0).fmt.hyperlink,
        'https://example.com',
      );
      expect(controller.activeBuffer.getCell(0, 1).fmt.hyperlink, isNull);
    });

    test('hyperlinkAt returns the URL at the given cell', () {
      controller.feed(
        '$kSeqEscape]8;;https://example.com\x07x$kSeqEscape]8;;\x07',
      );
      expect(controller.hyperlinkAt(0, 0), 'https://example.com');
      expect(controller.hyperlinkAt(0, 5), isNull);
    });

    test('params before the URI are accepted and ignored', () {
      controller.feed('$kSeqEscape]8;id=42;https://example.com\x07x\x07');
      expect(
        controller.activeBuffer.getCell(0, 0).fmt.hyperlink,
        'https://example.com',
      );
    });
  });
}
