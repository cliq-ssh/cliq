import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/modules/identities/ui/identity_card.dart';
import 'package:cliq/modules/identities/view/create_or_edit_identity_view.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
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
  String get title => 'Identities';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final identities = ref.watch(identityProvider);

    return EntityCardView<IdentityFull>(
      entities: identities.entities,
      viewTypeKey: .identitiesCardViewType,
      noEntitiesTitle: 'No Identities',
      noEntitiesSubtitle:
          'Add your first identity by clicking the button below.',
      addEntityTitle: 'Add Identity',
      onAddEntity: () => Commons.showResponsiveDialog(
        (_) => CreateOrEditIdentityView.create(),
      ),
      filterableFields: (i) => [i.label, i.username],
      entityCardBuilder: (identity) => IdentityCard(identity: identity),
    );
  }
}
