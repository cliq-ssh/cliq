import 'package:cliq/modules/settings/model/known_host_full.model.dart';
import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/modules/settings/provider/known_host.provider.dart';
import 'package:cliq/modules/settings/ui/known_host_card.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const KnownHostsSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'known-hosts',
  );

  @override
  String get title => 'known_hosts'.tr();

  @override
  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) =>
      body;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final knownHosts = ref.watch(knownHostProvider);

    return EntityCardView<KnownHostFull>(
      entities: knownHosts.entities,
      entityCardBuilder: (knownHost) => KnownHostCard(knownHost: knownHost),
      viewTypeKey: .knownHostsCardViewType,
      noEntitiesTitle: 'known_hosts_empty'.tr(),
      noEntitiesSubtitle: 'known_hosts_empty_subtitle'.tr(),
      filterableFields: (k) => [?k.vault.owner, k.host],
      filterableVaultId: (k) => k.vaultId,
    );
  }
}
