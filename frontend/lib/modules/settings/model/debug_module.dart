import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/modules/settings/model/settings_module.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';

final class DebugModule extends SettingsModule {
  @override
  String get title => 'Debug';

  @override
  String? get description => 'Debug settings';

  @override
  IconData get iconData => LucideIcons.wrench;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CliqButton(label: Text('Reset SQLite database'), onPressed: () async {
        await CliqDatabase.connectionsRepository.deleteAll();
        await CliqDatabase.credentialsRepository.deleteAll();
        await CliqDatabase.identitiesRepository.deleteAll();
        await CliqDatabase.identityCredentialsRepository.deleteAll();
      },)
    ],);
  }
}
