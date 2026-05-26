import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Backspace (BS)
/// https://terminalguide.namepad.de/seq/a_c0-h/
void main() {
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  test('Backspace (BS)', () {
    controller.feed('abc\x08\x08d');
    expectCellAt(controller, 0, 0, ch: 'a');
    expectCellAt(controller, 0, 1, ch: 'd');
    expectCellAt(controller, 0, 2, ch: 'c');
  });
}
