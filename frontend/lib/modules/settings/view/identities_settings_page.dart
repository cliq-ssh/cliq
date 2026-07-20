import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/modules/identities/ui/identity_card.dart';
import 'package:cliq/modules/identities/view/create_or_edit_identity_view.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';
import '../../../shared/utils/commons.dart';
import '../../identities/model/identity_full.model.dart';

class IdentitiesSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'identities',
  );

  const IdentitiesSettingsPage({super.key});

  @override
  String get title => 'identities'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final identities = ref.watch(identityProvider);

    return EntityCardView<IdentityFull>(
      entities: identities.entities,
      viewTypeKey: .identitiesCardViewType,
      noEntitiesTitle: 'identities_empty'.tr(),
      noEntitiesSubtitle: 'identities_empty_subtitle'.tr(),
      addEntityTitle: 'identities_add'.tr(),
      onAddEntity: () => Commons.showResponsiveDialog(
        (_) => CreateOrEditIdentityView.create(),
        context: context,
      ),
      filterableFields: (i) => [i.vault.label, i.label, i.username],
      entityCardBuilder: (identity) => IdentityCard(identity: identity),
    );
  }
}
