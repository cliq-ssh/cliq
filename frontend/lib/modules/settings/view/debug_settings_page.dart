import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridRow, CliqGridContainer;
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';

class DebugSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'debug',
  );

  const DebugSettingsPage({super.key});

  @override
  String get title => 'Debug';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Column(
                  mainAxisAlignment: .center,
                  spacing: 20,
                  children: [
                    FCard(
                      child: Column(
                        spacing: 16,
                        children: [
                          Column(
                            spacing: 4,
                            children: [
                              for (final key in StoreKey.values)
                                Row(
                                  children: [
                                    Text(
                                      key.name,
                                      style: context.theme.typography.sm,
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const .only(right: 8.0),
                                      child: Text(
                                        key.readAsStringSync() ?? 'null',
                                        style: context.theme.typography.sm
                                            .copyWith(
                                              color: context
                                                  .theme
                                                  .colors
                                                  .mutedForeground,
                                            ),
                                      ),
                                    ),
                                    FButton.icon(
                                      variant: .destructive,
                                      onPress: () => key.delete(),
                                      child: Icon(LucideIcons.trash),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          FButton(
                            variant: .destructive,
                            child: Text('Reset KeyValueStore'),
                            onPress: () async {
                              for (final key in StoreKey.values) {
                                await key.delete();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
