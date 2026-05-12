import 'package:cliq_term/src/rendering/utils/terminal_shortcuts.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  group('TerminalShortcuts.controlCharacterForKey', () {
    test('maps Ctrl+C, Ctrl+D, and Ctrl+R control bytes', () {
      expect(
        TerminalShortcuts.controlCharacterForKey(LogicalKeyboardKey.keyC),
        equals('\x03'),
      );
      expect(
        TerminalShortcuts.controlCharacterForKey(LogicalKeyboardKey.keyD),
        equals('\x04'),
      );
      expect(
        TerminalShortcuts.controlCharacterForKey(LogicalKeyboardKey.keyR),
        equals('\x12'),
      );
    });

    test('maps the full ASCII control-letter range', () {
      expect(
        TerminalShortcuts.controlCharacterForKey(LogicalKeyboardKey.keyA),
        equals('\x01'),
      );
      expect(
        TerminalShortcuts.controlCharacterForKey(LogicalKeyboardKey.keyZ),
        equals('\x1A'),
      );
    });
  });
}
