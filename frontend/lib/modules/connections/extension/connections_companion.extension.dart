import 'package:cliq/modules/connections/model/connection_icon.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';

extension ConnectionsCompanionExtension on ConnectionsCompanion {
  static ConnectionsCompanion? tryFromJson(Map<String, dynamic>? json) {
    if (json == null ||
        json['id'] == null ||
        json['label'] == null ||
        json['address'] == null ||
        json['port'] == null ||
        json['iconColor'] == null ||
        json['iconBackgroundColor'] == null ||
        json['icon'] == null ||
        json['isIconAutoDetect'] == null ||
        json['usesDefaultThemeOverride'] == null) {
      return null;
    }

    final iconColor = ColorExtension.fromHex(json['iconColor'] as String);
    final iconBackgroundColor = ColorExtension.fromHex(
      json['iconBackgroundColor'] as String,
    );

    if (iconColor == null || iconBackgroundColor == null) {
      return null;
    }

    return ConnectionsCompanion(
      id: Value(json['id'] as int),
      label: Value(json['label'] as String),
      address: Value(json['address'] as String),
      port: Value(json['port'] as int),
      iconColor: Value(iconColor),
      iconBackgroundColor: Value(iconBackgroundColor),
      icon: Value(
        ConnectionIcon.values.firstWhere(
          (e) => e.name == json['icon'],
          orElse: () => ConnectionIcon.unknown,
        ),
      ),
      isIconAutoDetect: Value(json['isIconAutoDetect'] as bool),
      username: Value(json['username'] as String?),
      groupName: Value(json['groupName'] as String?),
      identityId: Value(json['identityId'] as int?),
      terminalTypographyOverride: Value.absentIfNull(
        TerminalTypography.fromJson(json['terminalTypographyOverride']),
      ),
      terminalThemeOverrideId: Value(json['terminalThemeOverrideId'] as int?),
      usesDefaultThemeOverride: Value(json['usesDefaultThemeOverride'] as bool),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'label': label.value,
      'address': address.value,
      'port': port.value,
      'iconColor': iconColor.value.toHex(),
      'iconBackgroundColor': iconBackgroundColor.value.toHex(),
      'icon': icon.value.name,
      'isIconAutoDetect': isIconAutoDetect.value,
      if (username.value != null) 'username': username.value,
      if (groupName.value != null) 'groupName': groupName.value,
      if (identityId.value != null) 'identityId': identityId.value,
      if (terminalTypographyOverride.value != null)
        'terminalTypographyOverride': terminalTypographyOverride.value!
            .toJson(),
      if (terminalThemeOverrideId.value != null)
        'terminalThemeOverrideId': terminalThemeOverrideId.value,
      'usesDefaultThemeOverride': usesDefaultThemeOverride.value,
    };
  }
}
