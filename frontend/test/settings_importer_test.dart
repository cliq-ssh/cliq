import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_utils.dart';

const Map<SettingsImporter, String> sampleFiles = {
  .cliq: 'cliq_settings_export.json',
};

void main() {
  for (final parser in SettingsImporter.values) {
    late String path;
    late String content;

    setUp(() async {
      final file = await TestUtils.readFile(
        sampleFiles[parser]!,
        'settings_importer',
      );
      path = file.path;
      content = await file.readAsString();
    });

    group(parser.instance.runtimeType, () {
      test(
        'getParser: Return ${parser.instance.runtimeType} for valid ${parser.name} file',
        () async {
          final result = SettingsImporter.getParser(path, content);

          expect(result, isNotNull);
          expect(result.runtimeType, parser.instance.runtimeType);
        },
      );

      test(
        'canParse: Return true for valid ${parser.name} file content',
        () async {
          final canParse = await parser.instance.canParse(path, content);
          expect(canParse, isTrue);
        },
      );

      test(
        'tryParse: Successfully parse valid ${parser.name} file content',
        () async {
          final theme = await parser.instance.tryParse(path, content);
          expect(theme, isNotNull);
        },
      );
    });
  }
}
