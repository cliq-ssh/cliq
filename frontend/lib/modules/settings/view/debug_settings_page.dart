import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routing/page_path.dart';
import '../../../shared/data/sqlite/database.dart';

class DebugSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'debug',
  );

  const DebugSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FButton(
          child: Text('Reset SQLite database'),
          onPress: () async {
            await CliqDatabase.connectionsRepository.deleteAll();
            await CliqDatabase.credentialsRepository.deleteAll();
            await CliqDatabase.identitiesRepository.deleteAll();
          },
        ),
      ],
    );
  }
}
