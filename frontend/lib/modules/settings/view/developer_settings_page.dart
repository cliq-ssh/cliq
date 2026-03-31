import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridRow, CliqGridContainer;
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/database.dart';
import '../../../shared/model/page_path.model.dart';
import '../../../shared/utils/commons.dart' show Commons;

class DeveloperSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'developer',
  );

  const DeveloperSettingsPage({super.key});

  @override
  String get title => 'Developer';

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
                  spacing: 16,
                  children: [
                    FTileGroup(
                      label: Text('Tools'),
                      children: [
                        FTile(
                          prefix: Icon(LucideIcons.bugPlay),
                          title: Text('Throw sample error'),
                          onPress: () => throw Error(),
                        ),
                      ],
                    ),
                    FTileGroup(
                      label: Text('Database'),
                      children: [
                        // TODO move to commons?
                        FTile(
                          variant: .destructive,
                          prefix: Icon(LucideIcons.databaseBackup),
                          title: Text('Reset Database Tables'),
                          onPress: () => Commons.showDeleteDialog(
                            entity: 'ALL DATABASE TABLES',
                            onDelete: () =>
                                CliqDatabase.instance.deleteAllTables(),
                            canInstantDelete: false,
                            mayNeedAppRestart: true,
                          ),
                        ),
                      ],
                    ),
                    FTileGroup(
                      label: Text('KeyValueStore'),
                      children: [
                        FTile(
                          variant: .destructive,
                          prefix: Icon(LucideIcons.databaseBackup),
                          title: Text('Reset KeyValueStore'),
                          onPress: () async {
                            for (final key in StoreKey.values) {
                              await key.delete();
                            }
                          },
                        ),
                      ],
                    ),
                    FTileGroup(
                      divider: .full,
                      children: [
                        for (final key in StoreKey.values)
                          FTile(
                            title: Text(key.name),
                            subtitle: Text(key.readAsStringSync() ?? 'null'),
                            suffix: FButton.icon(
                              variant: .destructive,
                              onPress: () => key.delete(),
                              child: Icon(LucideIcons.trash),
                            ),
                          ),
                      ],
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
