import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';

extension KeysCompanionExtension on KeysCompanion {
  static KeysCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null || json['id'] == null || json['vaultId'] == null) {
      return null;
    }

    return KeysCompanion(
      id: Value(json['id'] as int),
      vaultId: Value(json['vaultId'] as int),
      label: Value(json['label'] as String? ?? ''),
      privatePem: Value(json['privatePem'] as String? ?? ''),
      passphrase: Value(json['passphrase'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'vaultId': vaultId.value,
      'label': label.value,
      'privatePem': privatePem.value,
      if (passphrase.value != null) 'passphrase': passphrase.value,
    };
  }
}
