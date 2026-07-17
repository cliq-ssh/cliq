import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Push Terminal Title + Pop Terminal Title
/// https://terminalguide.namepad.de/seq/csi_st-22/
/// https://terminalguide.namepad.de/seq/csi_st-23/
void main() {
  String? newTitle;
  late TerminalController controller;

  setUp(() {
    newTitle = null;
    controller = TerminalTestUtils.createController(
      onTitleChange: (title) => newTitle = title,
    );
  });

  group('Push Terminal Title + Pop Terminal Title', () {
    test('push then change then pop restores the previous title', () {
      controller.feed('$kSeqEscape]2;first\x07');
      expect(newTitle, 'first');

      controller.feed('$kSeqEscape[22t');

      controller.feed('$kSeqEscape]2;second\x07');
      expect(newTitle, 'second');

      controller.feed('$kSeqEscape[23t');
      expect(newTitle, 'first');
    });

    test('supports nested push/pop', () {
      controller.feed('$kSeqEscape]2;a\x07');
      controller.feed('$kSeqEscape[22t');
      controller.feed('$kSeqEscape]2;b\x07');
      controller.feed('$kSeqEscape[22t');
      controller.feed('$kSeqEscape]2;c\x07');

      controller.feed('$kSeqEscape[23t');
      expect(newTitle, 'b');

      controller.feed('$kSeqEscape[23t');
      expect(newTitle, 'a');
    });

    test(
      'pop with an empty stack does not crash and leaves title unchanged',
      () {
        controller.feed('$kSeqEscape]2;only\x07');
        expect(() => controller.feed('$kSeqEscape[23t'), returnsNormally);
        expect(newTitle, 'only');
      },
    );

    test('push/pop accepts an explicit Ps2 sub-parameter', () {
      controller.feed('$kSeqEscape]2;a\x07');
      controller.feed('$kSeqEscape[22;2t'); // push (window title only)
      controller.feed('$kSeqEscape]2;b\x07');
      controller.feed('$kSeqEscape[23;2t'); // pop (window title only)
      expect(newTitle, 'a');
    });
  });
}
