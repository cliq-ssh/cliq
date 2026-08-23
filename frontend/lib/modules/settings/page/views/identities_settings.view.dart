import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/modules/identities/ui/create_or_edit_identity_sheet.dart';
import 'package:cliq/modules/identities/ui/identity_card.dart';
import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const IdentitiesSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'identities',
  );

  @override
  String get title => 'identities'.tr();

  @override
  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) =>
      body;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final identities = ref.watch(identityProvider);

    return EntityCardView<IdentityFull>(
      entities: identities.entities,
      viewTypeKey: .identitiesCardViewType,
      noEntitiesTitle: 'identities_empty'.tr(),
      noEntitiesSubtitle: 'identities_empty_subtitle'.tr(),
      addEntityTitle: 'identities_add'.tr(),
      onAddEntity: () => Commons.showResponsiveSheet(
        (_) => const CreateOrEditIdentitySheet.create(),
        context: context,
      ),
      filterableFields: (i) => [?i.vault.owner, i.label, i.username],
      filterableVaultId: (i) => i.vaultId,
      entityCardBuilder: (identity) => IdentityCard(identity: identity),
    );
  }
}
