import 'dart:io';

import 'package:cliq/modules/settings/model/import/app_settings.model.dart';
import 'package:cliq/modules/settings/model/import/cliq_settings_importer.dart';
import 'package:cliq/modules/settings/model/import/ssh_config_settings_importer.dart';

enum SettingsImporter {
  cliq(CliqSettingsImporter(), fileExtension: 'json'),
  sshConfig(SSHConfigSettingsImporter());

  final AbstractSettingsImporter instance;
  final String? fileExtension;

  const SettingsImporter(this.instance, {this.fileExtension});

  static AbstractSettingsImporter? getParser(File file) {
    final lastSegment = file.uri.pathSegments.last;

    final fileExtension = lastSegment.split('.').last;
    final parsers =
        lastSegment.contains('.') // check if there is an extension
        ? SettingsImporter.values.where(
            (p) => p.fileExtension == null || p.fileExtension == fileExtension,
          )
        : SettingsImporter.values;

    for (final parser in parsers) {
      if (parser.instance.canParse(file)) {
        return parser.instance;
      }
    }
    return null;
  }
}

abstract class AbstractSettingsImporter {
  const AbstractSettingsImporter();

  bool canParse(File file);
  AppSettings? tryParse(File file);
}
