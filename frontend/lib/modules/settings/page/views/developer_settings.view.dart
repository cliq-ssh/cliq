import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/model/page_path.model.dart';
import '../../../../shared/utils/commons.dart' show Commons;
import '../../../vaults/provider/vault.provider.dart';
import '../abstract_settings_page.dart';
import '../settings.page.dart';

class const DeveloperSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'developer',
  );

  @override
  String get title => 'Developer';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final sync = ref.read(syncProvider);

    return Column(
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
        if (sync.isConnected)
          FTileGroup(
            label: Text('Sync'),
            children: [
              FTile(
                prefix: Icon(LucideIcons.arrowUpFromLine),
                title: Text('Force push current vault'),
                variant: .destructive,
                onPress: () async {
                  final userVault = await ref
                      .read(vaultProvider.notifier)
                      .findOrCreateUserVault(sync.api!);
                  final pushResult = await ref
                      .read(syncProvider.notifier)
                      .pushVault(userVault.id);

                  if (pushResult) {
                    Commons.showToast('Successfully force-pushed vault');
                  }
                },
              ),
              FTile(
                prefix: Icon(LucideIcons.arrowUpFromLine),
                title: Text('Force pull current vault'),
                variant: .destructive,
                onPress: () async {
                  final userVault = await ref
                      .read(vaultProvider.notifier)
                      .findOrCreateUserVault(sync.api!);
                  final pullResult = await ref
                      .read(syncProvider.notifier)
                      .pullVault(
                        userVaultOverride: userVault,
                        ignoreShouldPull: true,
                      );

                  if (pullResult) {
                    Commons.showToast('Successfully force-pulled vault');
                  }
                },
              ),
            ],
          ),
        FTileGroup(
          label: Text('Database'),
          children: [
            // TODO move to commons?
            .tile(
              variant: .destructive,
              prefix: Icon(LucideIcons.databaseBackup),
              title: Text('Clear Database Tables'),
              subtitle: Text(
                "This will delete all data in the database tables, but keep the table structure intact.",
                overflow: .visible,
              ),
              onPress: () => Commons.showDeleteDialog(
                entity: 'ALL DATABASE TABLES',
                onDelete: () => ref.read(databaseProvider).deleteAllTables(),
                canInstantDelete: false,
                mayNeedAppRestart: true,
              ),
            ),
            .tile(
              variant: .destructive,
              prefix: Icon(LucideIcons.databaseX),
              title: Text('Delete Database File'),
              subtitle: Text(
                "This will delete the entire database file, including all tables and data. An app restart is REQUIRED after this action.",
                overflow: .visible,
              ),
              onPress: () => Commons.showDeleteDialog(
                entity: 'THE ENTIRE DATABASE',
                onDelete: () => ref.read(databaseProvider).deleteDatabaseFile(),
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
                subtitle: FutureBuilder(
                  future: key.readAsync(),
                  builder: (context, snap) =>
                      Text(!snap.hasData ? '--' : snap.data.toString()),
                ),
                prefix: Icon(key.isSecure ? LucideIcons.lock : LucideIcons.key),
                suffix: FButton.icon(
                  variant: .destructive,
                  onPress: () => key.delete(),
                  child: Icon(LucideIcons.trash),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
