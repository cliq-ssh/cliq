import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Shift Out (SO) / Shift In (SI)
/// https://terminalguide.namepad.de/seq/a_c0-n/
/// https://terminalguide.namepad.de/seq/a_c0-o/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Shift Out (SO) / Shift In (SI)', () {
    test('ESC ( 0 designates DEC special graphics into G0', () {
      controller.feed('\x1b(0'); // DEC
      controller.feed('\x6a'); // 'j' in DEC graphics should render as ┘
      expectCellAt(controller, 0, 0, ch: String.fromCharCode(0x2518));
    });

    test('ESC ( B restores ASCII into G0', () {
      controller.feed('\x1b(0'); // DEC
      controller.feed('\x1b(B'); // back to ASCII
      controller.feed('A');
      expectCellAt(controller, 0, 0, ch: 'A');
    });

    test('SO switches to G1, SI switches back to G0', () {
      controller.feed('\x1b(B');
      controller.feed('\x1b)0');
      controller.feed('\x0E');
      controller.feed('\x6a');
      expectCellAt(controller, 0, 0, ch: String.fromCharCode(0x2518));
      controller.feed('\x0F');
      controller.feed('A');
      expectCellAt(controller, 0, 1, ch: 'A');
    });

    test('ASCII chars unaffected when G0 is ASCII', () {
      controller.feed('\x1b(B'); // explicitly ASCII
      controller.feed('hello');

      expectCellAt(controller, 0, 0, ch: 'h');
      expectCellAt(controller, 0, 1, ch: 'e');
      expectCellAt(controller, 0, 2, ch: 'l');
      expectCellAt(controller, 0, 3, ch: 'l');
      expectCellAt(controller, 0, 4, ch: 'o');
    });

    test('charset saved and restored with cursor', () {
      controller.feed('\x1b(0'); // DEC
      controller.feed('\x1b7'); // save cursor + charset
      controller.feed('\x1b(B'); // ASCII
      controller.feed('\x1b8'); // restore cursor
      controller.feed('\x6a');
      expectCellAt(controller, 0, 0, ch: String.fromCharCode(0x2518));
    });
  });
}
