import 'package:cliq_term/cliq_term.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/terminal_test_utils.dart';

/// Select Cursor Style (DECSCUSR)
/// https://terminalguide.namepad.de/seq/csi_sq_t_space/
///
/// https://terminalguide.namepad.de/seq/csi_sq_t_space-1/
/// https://terminalguide.namepad.de/seq/csi_sq_t_space-2/
/// https://terminalguide.namepad.de/seq/csi_sq_t_space-3/
/// https://terminalguide.namepad.de/seq/csi_sq_t_space-4/
/// https://terminalguide.namepad.de/seq/csi_sq_t_space-5/
/// https://terminalguide.namepad.de/seq/csi_sq_t_space-6/
void main() {
  /// Defines the modes that correspond to each cursor style.
  const Map<CursorStyle, List<int>> styleModesMap = {
    .block: [0, 1, 2],
    .underline: [3, 4],
    .bar: [5, 6],
  };

  /// `true` defined the modes that are considered "steady" (non-blinking) for each cursor style.
  /// `false` defines the modes that are considered "blinking".
  const Map<bool, List<int>> steadyModesMap = {
    true: [2, 4, 6],
    false: [0, 1, 3, 5],
  };

  late TerminalController controller;

  setUp(() {
    controller = TerminalTestUtils.createController();
  });

  group('Set Cursor Style (DECSCUSR)', () {
    for (final entry in styleModesMap.entries) {
      final style = entry.key;
      final modes = entry.value;

      for (final mode in modes) {
        test('mode $mode sets ${style.name} cursor', () {
          controller.feed('$kSeqEscape[$mode q');
          expect(controller.cursor.style, style);
        });
      }
    }

    for (final entry in steadyModesMap.entries) {
      final isSteady = entry.key;
      final modes = entry.value;

      for (final mode in modes) {
        test('mode $mode sets ${isSteady ? "steady" : "blinking"} cursor', () {
          controller.feed('$kSeqEscape[$mode q');
          expect(controller.cursorBlinkInterval == .zero, isSteady);
        });
      }
    }

    test('defaults to mode 1 (block) when no parameter is given', () {
      controller.feed('$kSeqEscape[ q');
      expect(controller.cursor.style, CursorStyle.block);
    });

    test('CSI q without the space intermediate is ignored', () {
      controller.cursor = controller.cursor.copyWith(style: CursorStyle.bar);
      controller.feed('$kSeqEscape[3q');
      expect(controller.cursor.style, CursorStyle.bar);
    });
  });
}
