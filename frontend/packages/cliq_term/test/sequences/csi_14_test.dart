import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Report Terminal Window Size in Pixels
/// https://terminalguide.namepad.de/seq/csi_st-14/
void main() {
  String? reply;
  late TerminalController controller;

  setUp(() {
    reply = null;
    controller = TerminalTestUtils.createController(
      onInput: (data) => reply = data,
    );
  });

  group('Report Terminal Window Size in Pixels', () {
    test('replies with CSI 4 ; height ; width t', () {
      controller.feed('$kSeqEscape[14t');
      expect(reply, isNotNull);
      expect(
        RegExp(r'^\x1b\[4;\d+;\d+t$').hasMatch(reply!),
        isTrue,
        reason: 'Expected reply matching CSI 4;height;width t, got "$reply"',
      );
    });
  });
}
