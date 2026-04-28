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
  Future<bool> canParse(String path, String content, {String? password}) async {
    if (content.length % 4 == 0 &&
        RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(content)) {
      content = utf8.decode(
        await _decodeAndDecrypt(content, password: password),
      );
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
  Future<AppSettings?> tryParse(
    String path,
    String content, {
    String? password,
  }) async {
    final json = jsonDecode(
      utf8.decode(await _decodeAndDecrypt(content, password: password)),
    );
    return AppSettings.tryFromJson(json);
  }

  Future<Uint8List> _decodeAndDecrypt(
    String content, {
    String? password,
  }) async {
    Uint8List decoded = base64Decode(content);
    if (PasswordCipher.instance.isEncrypted(decoded)) {
      if (password == null) {
        throw LocalizedException('settings.import.error.encryptedFile');
      }
      try {
        decoded = await PasswordCipher.instance.decrypt(
          decoded,
          utf8.encode(password),
        );
      } catch (e) {
        throw LocalizedException('settings.import.error.incorrectPassword');
      }
    }
    return decoded;
  }
}
