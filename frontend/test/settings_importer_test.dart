import 'dart:io';

import 'package:cliq/modules/settings/model/import/settings_importer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_utils.dart';

const Map<SettingsImporter, String> sampleFiles = {.sshConfig: 'config'};

void main() {
  for (final parser in SettingsImporter.values) {
    late File file;

    setUp(() async {
      file = await TestUtils.readFile(
        sampleFiles[parser]!,
        'settings_importer',
      );
    });

    group(parser.instance.runtimeType, () {
      test(
        'getParser: Return ${parser.instance.runtimeType} for valid ${parser.name} file',
        () async {
          final result = SettingsImporter.getParser(file);

          expect(result, isNotNull);
          expect(result.runtimeType, parser.instance.runtimeType);
        },
      );

      test(
        'canParse: Return true for valid ${parser.name} file content',
        () async {
          final canParse = parser.instance.canParse(file);
          expect(canParse, isTrue);
        },
      );

      test(
        'tryParse: Successfully parse valid ${parser.name} file content',
        () async {
          final theme = parser.instance.tryParse(file);
          expect(theme, isNotNull);
        },
      );
    });
  }
}
