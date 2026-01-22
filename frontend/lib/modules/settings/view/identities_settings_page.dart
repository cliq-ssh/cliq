import 'package:cliq/modules/identities/provider/identity.provider.dart';
import 'package:cliq/modules/identities/ui/identity_card.dart';
import 'package:cliq/modules/identities/view/create_or_edit_identity_view.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';
import '../../../shared/utils/commons.dart';

class IdentitiesSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'identities',
  );

  const IdentitiesSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final identities = ref.watch(identityProvider);

    openAddIdentityView() => Commons.showResponsiveDialog(
      context,
      (_) => CreateOrEditIdentityView.create(),
    );

    buildNoIdentities() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: {.sm: 12, .md: 8},
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No Identities',
                      textAlign: TextAlign.center,
                      style: context.theme.typography.xl2,
                    ),
                    Text(
                      'Add your first identity by clicking the button below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    FButton(
                      prefix: Icon(LucideIcons.plus),
                      onPress: openAddIdentityView,
                      child: Text('Add Identity'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return identities.entities.isEmpty
        ? buildNoIdentities()
        : SingleChildScrollView(
            child: CliqGridContainer(
              children: [
                CliqGridRow(
                  children: [
                    CliqGridColumn(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FButton(
                              style: FButtonStyle.ghost(),
                              prefix: Icon(LucideIcons.plus),
                              onPress: openAddIdentityView,
                              child: Text('Add Identity'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CliqGridColumn(
                      sizes: {.sm: 12, .md: 8},
                      child: Column(
                        spacing: 16,
                        children: [
                          for (final identity in identities.entities)
                            IdentityCard(identity: identity),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
