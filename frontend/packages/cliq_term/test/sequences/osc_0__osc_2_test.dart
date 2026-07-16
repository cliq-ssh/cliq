import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Set Window Title (OSC 0 / OSC 2)
/// https://terminalguide.namepad.de/seq/osc-0/
/// https://terminalguide.namepad.de/seq/osc-2/
void main() {
  String? newTitle;
  late TerminalController controller;

  setUp(() {
    newTitle = null;
    controller = TerminalTestUtils.createController(
      onTitleChange: (title) => newTitle = title,
    );
  });

  group('Set Window Title (OSC 0 / OSC 2)', () {
    test('OSC 2 sets the window title, terminated by BEL', () {
      controller.feed('$kSeqEscape]2;hello world\x07');
      expect(newTitle, 'hello world');
    });

    test('OSC 2 sets the window title, terminated by ST', () {
      controller.feed('$kSeqEscape]2;hello world$kSeqEscape\\');
      expect(newTitle, 'hello world');
    });

    test('title text may contain spaces and punctuation', () {
      controller.feed('$kSeqEscape]2;user@host: ~/projects (main)\x07');
      expect(newTitle, 'user@host: ~/projects (main)');
    });

    test('empty title is set when payload is empty', () {
      controller.feed('$kSeqEscape]2;\x07');
      expect(newTitle, '');
    });

    test('unterminated OSC sequence does not update the title', () {
      controller.feed('$kSeqEscape]2;incomplete title');
      expect(newTitle, isNot('incomplete title'));
    });
  });
}
