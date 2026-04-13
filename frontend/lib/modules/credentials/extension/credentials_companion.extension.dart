import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../model/credential_type.dart';

extension CredentialsCompanionExtension on CredentialsCompanion {
  static CredentialsCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null ||
        json['id'] == null ||
        json['vaultId'] == null ||
        json['type'] == null) {
      return null;
    }

    return CredentialsCompanion(
      id: Value(json['id'] as int),
      vaultId: Value(json['vaultId'] as int),
      type: Value(
        CredentialType.values.firstWhere(
          (e) => e.toString() == 'CredentialType.${json['type']}',
          orElse: () => CredentialType.password,
        ),
      ),
      keyId: Value(json['keyId'] as int?),
      password: Value(json['password'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'vaultId': vaultId.value,
      'type': type.value,
      if (keyId.value != null) 'keyId': keyId.value,
      if (password.value != null) 'password': password.value,
    };
  }
}
