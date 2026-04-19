import 'dart:convert';
import 'dart:typed_data';

import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/utils/password_cipher.dart';

/// Parser for the cliq settings export file. See [AppSettings} for details.
class CliqSettingsImporter extends AbstractSettingsImporter {
  const CliqSettingsImporter();

  @override
  bool canParse(String path, String content, {String? password}) {
    if (content.length % 4 == 0 &&
        RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(content)) {
      content = utf8.decode(decodeAndDecrypt(content, password: password));
    } else {
      // if its not valid base64, it cant be a cliq settings file
      return false;
    }

    try {
      // check if its valid json
      jsonDecode(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  AppSettings? tryParse(String path, String content, {String? password}) {
    final json = jsonDecode(
      utf8.decode(decodeAndDecrypt(content, password: password)),
    );
    return AppSettings.tryFromJson(json);
  }

  Uint8List decodeAndDecrypt(String content, {String? password}) {
    Uint8List decoded = base64Decode(content);
    if (PasswordCipher.isEncrypted(decoded)) {
      if (password == null) {
        throw LocalizedException('settings.import.error.encryptedFile');
      }
      try {
        decoded = PasswordCipher.decrypt(decoded, password);
      } catch (e) {
        throw LocalizedException('settings.import.error.incorrectPassword');
      }
    }
    return decoded;
  }
}
