import 'package:cliq/modules/settings/model/known_host_full.model.dart';
import 'package:cliq/modules/settings/provider/known_host.provider.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';
import '../ui/known_host_card.dart';

class KnownHostsSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'known-hosts',
  );

  const KnownHostsSettingsPage({super.key});

  @override
  String get title => 'known_hosts'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final knownHosts = ref.watch(knownHostProvider);

    return EntityCardView<KnownHostFull>(
      entities: knownHosts.entities,
      entityCardBuilder: (knownHost) => KnownHostCard(knownHost: knownHost),
      viewTypeKey: .knownHostsCardViewType,
      noEntitiesTitle: 'known_hosts_empty'.tr(),
      noEntitiesSubtitle: 'known_hosts_empty_subtitle'.tr(),
      filterableFields: (k) => [k.vault.label, k.host],
      filterableVaultId: (k) => k.vaultId,
    );
  }
}
