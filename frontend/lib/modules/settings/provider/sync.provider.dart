import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:file_selector/file_selector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/settings_importer/cliq_settings_importer.dart';
import '../model/sync.state.dart';

final syncProvider = NotifierProvider(SyncProviderNotifier.new);

class SyncProviderNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => .initial();

  /// Attempts to parse the given [file] as [AppSettings].
  /// If the file is null, not parsable, or fails for any reason, this method throws the i18n key of the error message.
  Future<AppSettings?> tryParseSettings(XFile? file, {String? password}) async {
    if (file == null) {
      return null;
    }
    final path = file.path;
    final content = await file.readAsString();

    final parser = SettingsImporter.getParser(
      path,
      content,
      password: password,
    );
    if (parser == null) {
      throw LocalizedException('settings.import.error.unrecognizedFormat');
    }

    AppSettings? settings;
    if (parser is CliqSettingsImporter) {
      settings = parser.tryParse(path, content, password: password);
    } else {
      settings = parser.tryParse(path, content);
    }

    if (settings == null) {
      throw LocalizedException('settings.import.error.parsingFailed');
    }
    return settings;
  }
}
