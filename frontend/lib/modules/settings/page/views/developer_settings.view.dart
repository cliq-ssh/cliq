import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/vaults/provider/vault.provider.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:cliq/shared/utils/build_metadata.dart';
import 'package:cliq/shared/utils/commons.dart' show Commons;
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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
          label: const Text('Info'),
          children: [
            FTile(
              prefix: const Icon(LucideIcons.tag),
              title: const Text('Version'),
              subtitle: const Text(BuildMetadata.version),
              suffix: const Icon(LucideIcons.copy),
              onPress: () =>
                  Commons.copyToClipboard(context, BuildMetadata.version),
            ),
            FTile(
              prefix: const Icon(LucideIcons.hash),
              title: const Text('Build number'),
              subtitle: const Text('${BuildMetadata.buildNumber}'),
              suffix: const Icon(LucideIcons.copy),
              onPress: () => Commons.copyToClipboard(
                context,
                '${BuildMetadata.buildNumber}',
              ),
            ),
            FTile(
              prefix: const Icon(LucideIcons.gitCommitHorizontal),
              title: const Text('Git SHA'),
              subtitle: const Text(BuildMetadata.gitSha, overflow: .visible),
              suffix: const Icon(LucideIcons.copy),
              onPress: () =>
                  Commons.copyToClipboard(context, BuildMetadata.gitSha),
            ),
            FTile(
              prefix: const Icon(LucideIcons.gitBranch),
              title: const Text('Git SHA (short)'),
              subtitle: const Text(BuildMetadata.gitShaShort),
              suffix: const Icon(LucideIcons.copy),
              onPress: () =>
                  Commons.copyToClipboard(context, BuildMetadata.gitShaShort),
            ),
            FTile(
              prefix: const Icon(LucideIcons.layers),
              title: const Text('Release channel'),
              subtitle: const Text(BuildMetadata.releaseChannelValue),
              suffix: const Icon(LucideIcons.copy),
              onPress: () => Commons.copyToClipboard(
                context,
                BuildMetadata.releaseChannelValue,
              ),
            ),
          ],
        ),
        FTileGroup(
          label: const Text('Tools'),
          children: [
            FTile(
              prefix: const Icon(LucideIcons.bugPlay),
              title: const Text('Throw sample error'),
              onPress: () => throw Error(),
            ),
          ],
        ),
        if (sync.isConnected)
          FTileGroup(
            label: const Text('Sync'),
            children: [
              FTile(
                prefix: const Icon(LucideIcons.arrowUpFromLine),
                title: const Text('Force push current vault'),
                variant: .destructive,
                onPress: () async {
                  final userVault = await ref
                      .read(vaultProvider.notifier)
                      .findOrCreateUserVault(sync.api!);
                  final pushResult = await ref
                      .read(syncProvider.notifier)
                      .pushVault(userVault.id);

                  if (pushResult) {
                    await Commons.showToast('Successfully force-pushed vault');
                  }
                },
              ),
              FTile(
                prefix: const Icon(LucideIcons.arrowUpFromLine),
                title: const Text('Force pull current vault'),
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
                    await Commons.showToast('Successfully force-pulled vault');
                  }
                },
              ),
            ],
          ),
        FTileGroup(
          label: const Text('Database'),
          children: [
            // TODO move to commons?
            .tile(
              variant: .destructive,
              prefix: const Icon(LucideIcons.databaseBackup),
              title: const Text('Clear Database Tables'),
              subtitle: const Text(
                'This will delete all data in the database tables, but keep the table structure intact.',
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
              prefix: const Icon(LucideIcons.databaseX),
              title: const Text('Delete Database File'),
              subtitle: const Text(
                'This will delete the entire database file, including all tables and data. An app restart is REQUIRED after this action.',
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
          label: const Text('KeyValueStore'),
          children: [
            FTile(
              variant: .destructive,
              prefix: const Icon(LucideIcons.databaseBackup),
              title: const Text('Reset KeyValueStore'),
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
                  child: const Icon(LucideIcons.trash),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
