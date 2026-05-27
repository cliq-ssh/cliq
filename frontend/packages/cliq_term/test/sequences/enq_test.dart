import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Answerback (ENQ)
/// https://terminalguide.namepad.de/seq/a_c0-e/
void main() {
  late TerminalController controller;
  late List<String> outputs;

  setUp(() {
    controller = TerminalTestUtils.createController();
    outputs = [];
    controller.onInput = outputs.add;
  });

  group('Answerback (ENQ)', () {
    test('responds with empty answerback by default', () {
      controller.feed('\x05');
      expect(outputs, isEmpty);
    });

    test('responds with custom answerback string', () {
      controller.answerback = 'myterm';

      controller.feed('\x05');
      expect(outputs, equals(['myterm']));
    });
  });
}
