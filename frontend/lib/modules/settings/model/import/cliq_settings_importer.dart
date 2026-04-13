import 'dart:convert';
import 'dart:io';

import 'package:cliq/modules/settings/model/import/app_settings.model.dart';
import 'package:cliq/modules/settings/model/import/settings_importer.dart';

/// Parser for the cliq settings export file. See [AppSettings} for details.
class CliqSettingsImporter extends AbstractSettingsImporter {
  const CliqSettingsImporter();

  @override
  bool canParse(File file) {
    // check if file content is valid JSON (because of encrypted exports)
    try {
      final content = file.readAsStringSync();
      jsonDecode(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  AppSettings? tryParse(File file) {
    final json = jsonDecode(file.readAsStringSync());
    return AppSettings.tryFromJson(json);
  }
}
