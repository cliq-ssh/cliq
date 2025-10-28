import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routing/page_path.dart';

class IdentitiesSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'identities',
  );

  const IdentitiesSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Text('TODO');
  }
}
