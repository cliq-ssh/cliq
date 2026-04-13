import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

extension IdentitiesCompanionExtension on IdentitiesCompanion {
  static IdentitiesCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null || json['id'] == null || json['vaultId'] == null) {
      return null;
    }

    return IdentitiesCompanion(
      id: Value(json['id'] as int),
      vaultId: Value(json['vaultId'] as int),
      label: Value(json['label'] as String? ?? ''),
      username: Value(json['username'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'vaultId': vaultId.value,
      'label': label.value,
      'username': username.value,
    };
  }
}
