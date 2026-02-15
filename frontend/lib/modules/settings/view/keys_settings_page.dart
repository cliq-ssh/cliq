import 'package:cliq/modules/keys/view/create_or_edit_key_view.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:cliq_ui/hooks/use_memoized_future.export.dart'
    show useMemoizedFuture;
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';
import '../../../shared/extensions/async_snapshot.extension.dart';
import '../../../shared/model/page_path.model.dart';
import '../../../shared/utils/commons.dart';
import '../../keys/provider/key.provider.dart';
import '../../keys/ui/key_card.dart';

class KeysSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'keys',
  );

  const KeysSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final keyIds = ref.watch(keyIdProvider);
    final keysFuture = useMemoizedFuture(() async {
      return await CliqDatabase.keysService.findByIds(keyIds.entities);
    }, [keyIds]);

    openAddKeyView() => Commons.showResponsiveDialog(
      context,
      (_) => CreateOrEditKeyView.create(),
    );

    buildNoKeys() {
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
                      'No Keys',
                      textAlign: TextAlign.center,
                      style: context.theme.typography.xl2,
                    ),
                    Text(
                      'Add your first key by clicking the button below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    FButton(
                      prefix: Icon(LucideIcons.plus),
                      onPress: openAddKeyView,
                      child: Text('Add Key'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return keyIds.entities.isEmpty
        ? buildNoKeys()
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
                              variant: .ghost,
                              prefix: Icon(LucideIcons.plus),
                              onPress: openAddKeyView,
                              child: Text('Add Key'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CliqGridColumn(
                      sizes: {.sm: 12, .md: 8},
                      child: keysFuture.on(
                        onLoading: () => Center(child: FCircularProgress()),
                        onData: (keys) {
                          return Column(
                            spacing: 16,
                            children: [
                              for (final key in keys) KeyCard(keyEntity: key),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
