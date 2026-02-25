import 'package:cliq/modules/settings/provider/known_host.provider.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../../../shared/model/page_path.model.dart';
import '../ui/known_host_card.dart';

class KnownHostsSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'known-hosts',
  );

  const KnownHostsSettingsPage({super.key});

  @override
  String get title => 'Known Hosts';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final knownHosts = ref.watch(knownHostProvider);

    return EntityCardView<KnownHost>(
      entities: knownHosts.entities,
      entityCardBuilder: (knownHost) => KnownHostCard(knownHost: knownHost),
      viewTypeKey: .knownHostsCardViewType,
      noEntitiesTitle: 'No Known Hosts',
      noEntitiesSubtitle:
          'No known hosts have been added yet. Connect to a host to add it to your known hosts list.',
      filterableFields: (k) => [k.host],
    );
  }
}
