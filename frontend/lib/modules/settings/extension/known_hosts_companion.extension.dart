import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';

extension KnownHostsCompanionExtension on KnownHostsCompanion {
  static KnownHostsCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null || json['id'] == null || json['vaultId'] == null) {
      return null;
    }

    return KnownHostsCompanion(
      id: Value(json['id'] as int),
      vaultId: Value(json['vaultId'] as int),
      host: Value(json['host'] as String? ?? ''),
      hostKey: Value(
        Uint8List.fromList(
          (List<int>.from(json['hostKey'] as List<dynamic>? ?? [])),
        ),
      ),
      createdAt: Value(
        DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'vaultId': vaultId.value,
      'host': host.value,
      'hostKey': hostKey.value.toList(),
      'createdAt': createdAt.value.millisecondsSinceEpoch,
    };
  }
}
