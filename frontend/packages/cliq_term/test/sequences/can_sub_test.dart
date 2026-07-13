import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Cancel Parsing (CAN / SUB)
/// https://terminalguide.namepad.de/seq/a_c0-x/
/// https://terminalguide.namepad.de/seq/a_c0-z/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  /// Cancels an in-progress escape sequence, preventing it from executing.
  testCancelsSequence(String cancelByte) {
    // ESC [ cancelled, 'b' prints normally
    controller.feed('$kSeqEscape[${cancelByte}b');
    // cursor advanced past 'b'
    expectCursorAt(controller, 0, 1);
    expectCellAt(controller, 0, 0, ch: 'b');
  }

  /// The cancel byte should not affect normal input if it's not part of a sequence.
  testDoesNotAffectNormalInputOutsideSequence(String cancelByte) {
    controller.feed('a${cancelByte}b');
    expectCellAt(controller, 0, 0, ch: 'a');
    expectCellAt(controller, 0, 1, ch: 'b');
  }

  group('Cancel Parsing (CAN)', () {
    test(
      'cancels in-progress escape sequence',
      () => testCancelsSequence('\x18'),
    );
    test(
      'does not affect normal input outside a sequence',
      () => testDoesNotAffectNormalInputOutsideSequence('\x18'),
    );
  });

  group('Cancel Parsing (SUB)', () {
    test(
      'cancels in-progress escape sequence',
      () => testCancelsSequence('\x1A'),
    );
    test(
      'does not affect normal input outside a sequence',
      () => testDoesNotAffectNormalInputOutsideSequence('\x1A'),
    );
  });
}
