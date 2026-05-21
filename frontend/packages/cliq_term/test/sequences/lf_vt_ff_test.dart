import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Line Feed (LF) / Vertical Tab (VT) / Form Feed (FF)
/// https://terminalguide.namepad.de/seq/a_c0-j/
/// https://terminalguide.namepad.de/seq/a_c0-k/ (same as LF)
/// https://terminalguide.namepad.de/seq/a_c0-l/ (same as LF)
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  const String lfInput = 'ab\x0Ac';
  const String vtInput = 'ab\x0Bc';
  const String ffInput = 'ab\x0Cc';

  /// By default, LF moves the cursor down but does not change the column.
  testMoveCursorDownWithoutChangingColumn(String input) {
    controller.feed(input); // cursor at col 2 after 'ab', then LF
    TerminalTestUtils.expectCellAt(controller, 0, 0, ch: 'a');
    TerminalTestUtils.expectCellAt(controller, 0, 1, ch: 'b');
    TerminalTestUtils.expectCellAt(controller, 1, 2, ch: 'c'); // col preserved
  }

  /// With linefeed mode enabled, LF also resets the column to 0.
  testLineFeedWithLinefeedMode(String input) {
    controller.setLineFeedMode(true);
    controller.feed(input);
    TerminalTestUtils.expectCellAt(controller, 0, 0, ch: 'a');
    TerminalTestUtils.expectCellAt(controller, 0, 1, ch: 'b');
    TerminalTestUtils.expectCellAt(controller, 1, 0, ch: 'c'); // col reset to 0
  }

  group('Line Feed (LF)', () {
    test('moves cursor down without changing column', () => testMoveCursorDownWithoutChangingColumn(lfInput));
    test('with linefeed mode, also resets cursor to column 0', () => testLineFeedWithLinefeedMode(lfInput));
  });

  group('Vertical Tab (VT)', () {
    test('moves cursor down without changing column', () => testMoveCursorDownWithoutChangingColumn(vtInput));
    test('with linefeed mode, also resets cursor to column 0', () => testLineFeedWithLinefeedMode(vtInput));
  });

  group('Form Feed (FF)', () {
    test('moves cursor down without changing column', () => testMoveCursorDownWithoutChangingColumn(ffInput));
    test('with linefeed mode, also resets cursor to column 0', () => testLineFeedWithLinefeedMode(ffInput));
  });
}

