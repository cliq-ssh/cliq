import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';

extension KeysCompanionExtension on KeysCompanion {
  static KeysCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null ||
        json['id'] == null ||
        json['label'] == null ||
        json['privateKey'] == null) {
      return null;
    }

    return KeysCompanion(
      id: Value(json['id'] as int),
      label: Value(json['label'] as String),
      privateKey: Value(json['privateKey'] as String),
      publicKey: Value(json['publicKey'] as String?),
      passphrase: Value(json['passphrase'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'label': label.value,
      'privateKey': privateKey.value,
      if (publicKey.value != null) 'publicKey': publicKey.value,
      if (passphrase.value != null) 'passphrase': passphrase.value,
    };
  }
}
