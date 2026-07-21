import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/terminal_test_utils.dart';

void main() {
  TerminalController buildController({
    bool defaultAlternateScrollMode = true,
  }) => TerminalTestUtils.createController(
    defaultAlternateScrollMode: defaultAlternateScrollMode,
  );

  group('Alternate Scroll Mode default + reset behavior', () {
    test('defaults to true when not overridden', () {
      final controller = buildController();
      expect(controller.alternateScrollMode, isTrue);
    });

    test('can be constructed with a false default', () {
      final controller = buildController(defaultAlternateScrollMode: false);
      expect(controller.alternateScrollMode, isFalse);
    });

    test('an app disabling it mid-session is respected for that session', () {
      final controller = buildController();
      controller.feed('$kSeqEscape[?1049h');
      controller.feed('$kSeqEscape[?1007l');
      expect(controller.alternateScrollMode, isFalse);

      final handled = controller.handleScroll(row: 0, col: 0, up: true);
      expect(handled, isFalse);
    });

    test(
      'a fresh CSI ?1049h entry resets to the default, undoing a prior app forgetting to restore it',
      () {
        final controller = buildController();
        controller.feed('$kSeqEscape[?1049h');
        controller.feed(
          '$kSeqEscape[?1007l',
        ); // app disables it, forgets to restore
        controller.feed('$kSeqEscape[?1049l'); // app exits back to main screen
        controller.feed(
          '$kSeqEscape[?1049h',
        ); // a NEW app enters the alt screen

        expect(controller.alternateScrollMode, isTrue);
      },
    );

    test('tCSI ?47/?1047 toggle does not reset the mode', () {
      final controller = buildController();
      controller.feed('$kSeqEscape[?1007l');
      controller.feed('$kSeqEscape[?47h'); // legacy alt-screen toggle
      expect(controller.alternateScrollMode, isFalse);
    });
  });
}
