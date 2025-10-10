import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../data/sqlite/database.dart';
import '../../../routing/page_path.dart';

class DebugSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'debug',
  );

  const DebugSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        CliqButton(
          label: Text('Reset SQLite database'),
          onPressed: () async {
            await CliqDatabase.connectionsRepository.deleteAll();
            await CliqDatabase.credentialsRepository.deleteAll();
            await CliqDatabase.identitiesRepository.deleteAll();
            await CliqDatabase.identityCredentialsRepository.deleteAll();
          },
        ),
      ],
    );
  }
}
