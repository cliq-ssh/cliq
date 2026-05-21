import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Bell (BEL)
/// https://terminalguide.namepad.de/seq/a_c0-g/
void main() {
  bool bellCalled = false;
  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController(
      onBell: () => bellCalled = true,
    );
  });

  test('Bell (BEL)', () {
    controller.feed('\x07');
    expect(bellCalled, isTrue);
  });
}
