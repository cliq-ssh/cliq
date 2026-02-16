import 'dart:io';

import 'package:cliq/modules/settings/model/terminal_theme_parser/kitty_terminal_theme_parser.dart';
import 'package:cliq/modules/settings/model/terminal_theme_parser/terminal_theme_parser.dart';
import 'package:cliq/modules/settings/model/terminal_theme_parser/windows_terminal_theme_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper function to read a resource file as a string.
  /// If [makeInvalid] is true, it will return only the first half of the content to simulate an invalid file.
  Future<(String, String)> readResource(
    String fileName, {
    bool makeInvalid = false,
  }) async {
    final file = File('${Directory.current.path}/test/resources/$fileName');
    final content = await file.readAsString();
    return (
      file.uri.pathSegments.last,
      makeInvalid
          // halve the content to make it invalid
          ? content.substring(0, content.length ~/ 2)
          : content,
    );
  }

  group('WindowsTerminalThemeParser', () {
    test('get correct parser & parse', () async {
      final (fileName, content) = await readResource('Apple Classic.json');
      final parser = TerminalThemeParser.getParser(fileName, content);

      expect(parser, isNotNull);
      expect(parser.runtimeType, WindowsTerminalThemeParser);

      final theme = parser!.tryParse(fileName, content);

      expect(theme, isNotNull);
      expect(theme!.name.value, 'Apple Classic');
    });

    test('fail to parse invalid content', () async {
      final (fileName, content) = await readResource(
        'Apple Classic.json',
        makeInvalid: true,
      );
      final result = WindowsTerminalThemeParser().tryParse(fileName, content);
      expect(result, isNull);
    });
  });

  group('KittyTerminalThemeParser', () {
    test('get correct parser & parse', () async {
      final (fileName, content) = await readResource('Apple Classic.conf');
      final parser = TerminalThemeParser.getParser(fileName, content);

      expect(parser, isNotNull);
      expect(parser.runtimeType, KittyTerminalThemeParser);

      final theme = parser!.tryParse(fileName, content);

      expect(theme, isNotNull);
      expect(theme!.name.value, 'Apple Classic');
    });

    test('fail to parse invalid content', () async {
      final (fileName, content) = await readResource(
        'Apple Classic.conf',
        makeInvalid: true,
      );
      final result = KittyTerminalThemeParser().tryParse(fileName, content);
      expect(result, isNull);
    });
  });
}
