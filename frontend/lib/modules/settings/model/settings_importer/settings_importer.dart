import 'dart:io';

import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/cliq_settings_importer.dart';

enum SettingsImporter {
  cliq(CliqSettingsImporter(), fileExtension: 'txt'),
  ;

  final AbstractSettingsImporter instance;
  final String? fileExtension;

  const SettingsImporter(this.instance, {this.fileExtension});

  static Future<AbstractSettingsImporter?> getParser(
    String path,
    String content, {
    String? password,
  }) async {
    final lastSegment = path.split(Platform.pathSeparator).last;

    final fileExtension = lastSegment.split('.').last;
    final parsers = SettingsImporter.values.where(
      (p) => p.fileExtension == fileExtension,
    );

    for (final parser in parsers) {
      if (parser.instance is CliqSettingsImporter &&
              await (parser.instance as CliqSettingsImporter).canParse(
                path,
                content,
                password: password,
              ) ||
          await parser.instance.canParse(path, content)) {
        return parser.instance;
      }
    }
    return null;
  }
}

abstract class AbstractSettingsImporter {
  const AbstractSettingsImporter();

  Future<bool> canParse(String path, String content);
  Future<AppSettings?> tryParse(String path, String content);
}
