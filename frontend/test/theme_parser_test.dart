import 'dart:io';

import 'package:cliq/modules/settings/model/terminal_theme_parser/terminal_theme_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<TerminalThemeParser, String> sampleFiles = {
  .windowsTerminal: 'Apple Classic.json',
  .kitty: 'Apple Classic.conf',
};

void main() {
  /// Helper function to read a resource file as a string.
  /// If [makeInvalid] is true, it will return only the first half of the content to simulate an invalid file.
  Future<(String, String)> readResource(String fileName) async {
    final file = File('${Directory.current.path}/test/resources/$fileName');
    return (file.uri.pathSegments.last, await file.readAsString());
  }

  for (final parser in TerminalThemeParser.values) {
    group(parser.abstractParser.runtimeType, () {
      test(
        'getParser: Return "${parser.abstractParser.runtimeType}" for valid ${parser.name} theme',
        () async {
          final (fileName, content) = await readResource(sampleFiles[parser]!);
          final result = TerminalThemeParser.getParser(fileName, content);
          expect(result, isNotNull);
          expect(result.runtimeType, parser.abstractParser.runtimeType);
        },
      );

      test(
        'canParse: Return true for valid ${parser.name} theme content',
        () async {
          final (fileName, content) = await readResource(sampleFiles[parser]!);
          final canParse = parser.abstractParser.canParse(content);
          expect(canParse, isTrue);
        },
      );

      test(
        'tryParse: Successfully parse valid ${parser.name} theme content',
        () async {
          final (fileName, content) = await readResource(sampleFiles[parser]!);
          final theme = parser.abstractParser.tryParse(fileName, content);
          expect(theme, isNotNull);
        },
      );
    });
  }
}
