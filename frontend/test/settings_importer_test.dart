import 'package:cliq/modules/settings/model/import/settings_importer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_utils.dart';

const Map<SettingsImporter, String> sampleFiles = {.sshConfig: 'config'};

void main() {
  for (final parser in SettingsImporter.values) {
    group(parser.instance.runtimeType, () {
      test(
        'getParser: Return ${parser.instance.runtimeType} for valid ${parser.name} file',
        () async {
          final file = await TestUtils.readFile(
            sampleFiles[parser]!,
            'settings_importer',
          );
          final result = SettingsImporter.getParser(file);

          expect(result, isNotNull);
          expect(result.runtimeType, parser.instance.runtimeType);
        },
      );
    });
  }
}
