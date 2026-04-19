import 'dart:io';

import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/cliq_settings_importer.dart';
import 'package:cliq/modules/settings/model/settings_importer/ssh_config_settings_importer.dart';

enum SettingsImporter {
  cliq(CliqSettingsImporter(), fileExtension: 'txt'),
  sshConfig(SSHConfigSettingsImporter());

  final AbstractSettingsImporter instance;
  final String? fileExtension;

  const SettingsImporter(this.instance, {this.fileExtension});

  static AbstractSettingsImporter? getParser(
    String path,
    String content, {
    String? password,
  }) {
    final lastSegment = path.split(Platform.pathSeparator).last;

    final fileExtension = lastSegment.split('.').last;
    final parsers = SettingsImporter.values.where(
      (p) => p.fileExtension == fileExtension,
    );

    for (final parser in parsers) {
      if (parser.instance is CliqSettingsImporter &&
              (parser.instance as CliqSettingsImporter).canParse(
                path,
                content,
                password: password,
              ) ||
          parser.instance.canParse(path, content)) {
        return parser.instance;
      }
    }
    return null;
  }
}

abstract class AbstractSettingsImporter {
  const AbstractSettingsImporter();

  bool canParse(String path, String content);
  AppSettings? tryParse(String path, String content);
}
