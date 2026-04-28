import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../model/credential_type.dart';

extension CredentialsCompanionExtension on CredentialsCompanion {
  static CredentialsCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null || json['id'] == null || json['type'] == null) {
      return null;
    }

    return CredentialsCompanion(
      id: Value(json['id'] as int),
      type: Value(
        CredentialType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () =>
              throw Exception('Unknown credential type: ${json['type']}'),
        ),
      ),
      keyId: Value(json['keyId'] as int?),
      password: Value(json['password'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'type': type.value.name,
      if (keyId.value != null) 'keyId': keyId.value,
      if (password.value != null) 'password': password.value,
    };
  }
}
