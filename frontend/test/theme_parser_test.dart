import 'package:cliq/modules/settings/model/theme_parser/terminal_theme_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_utils.dart';

const Map<TerminalThemeParser, String> sampleFiles = {
  .windowsTerminal: 'Apple Classic.json',
  .kitty: 'Apple Classic.conf',
};

void main() {
  for (final parser in TerminalThemeParser.values) {
    late String fileName;
    late String content;

    setUp(() async {
      final (f, c) = await TestUtils.readResource(
        sampleFiles[parser]!,
        'theme_parser',
      );
      fileName = f;
      content = c;
    });

    group(parser.instance.runtimeType, () {
      test(
        'getParser: Return ${parser.instance.runtimeType} for valid ${parser.name} theme',
        () async {
          final result = TerminalThemeParser.getParser(fileName, content);
          expect(result, isNotNull);
          expect(result.runtimeType, parser.instance.runtimeType);
        },
      );

      test(
        'canParse: Return true for valid ${parser.name} theme content',
        () async {
          final canParse = parser.instance.canParse(content);
          expect(canParse, isTrue);
        },
      );

      test(
        'tryParse: Successfully parse valid ${parser.name} theme content',
        () async {
          final theme = parser.instance.tryParse(fileName, content);
          expect(theme, isNotNull);
        },
      );
    });
  }
}
