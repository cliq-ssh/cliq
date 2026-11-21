import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/appearance_settings.page.dart';
import 'package:cliq/modules/settings/page/developer_settings.page.dart';
import 'package:cliq/modules/settings/page/i18n_settings.page.dart';
import 'package:cliq/modules/settings/page/identities_settings.page.dart';
import 'package:cliq/modules/settings/page/keys_settings.page.dart';
import 'package:cliq/modules/settings/page/known_hosts_settings.page.dart';
import 'package:cliq/modules/settings/page/licenses.page.dart';
import 'package:cliq/modules/settings/page/logs_settings.page.dart';
import 'package:cliq/modules/settings/page/shortcuts_settings.page.dart';
import 'package:cliq/modules/settings/page/ssh_sftp_settings.page.dart';
import 'package:cliq/modules/settings/page/sync_settings.page.dart';
import 'package:cliq/modules/settings/page/terminal_theme_settings.page.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/settings/ui/version_indicator.dart';
import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_grid/cliq_grid.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:simple_icons/simple_icons.dart';

class const SettingsPage({super.key}) extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/settings');

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NavigatorPopHandler(
      onPopWithResult: (r) => _navKey.currentState?.maybePop(r),
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (_) =>
            CupertinoPageRoute(builder: (_) => const _SettingsOverview()),
      ),
    );
  }
}

class const _SettingsOverview() extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);
    final developerMode = useStore(.developerMode);
    final lastUpdated = useState<double?>(null);

    useEffect(() {
      if (sync.api == null) return;
      final vaultService = ref.read(vaultServiceProvider);
      vaultService.findLatestUpdatedTimestamp().then((lastUpdatedValue) {
        lastUpdated.value = lastUpdatedValue;
      });

      return null;
    });

    buildStatusSubtitle() {
      if (sync.isError) {
        return Text('sync_error'.tr());
      }
      if (sync.isLikelyLoading) {
        return Text('sync_loading'.tr());
      }
      return Text(
        'sync_last_updated'.tr(
          args: [
            lastUpdated.value == null || lastUpdated.value == 0
                ? 'n_a'.tr()
                : DateTime.fromMillisecondsSinceEpoch(
                    lastUpdated.value!.toInt(),
                    isUtc: true,
                  ).toIso8601String(),
          ],
        ),
      );
    }

    buildSettingsTile({
      AbstractSettingsPage? settingsPage,
      IconData? prefix,
      IconData? suffix,
      Widget? subtitle,
      FItemVariant variant = .primary,
    }) {
      return FTile(
        prefix: prefix != null ? Icon(prefix) : null,
        suffix: suffix != null ? Icon(suffix) : null,
        variant: variant,
        title: Text(settingsPage!.title),
        subtitle: subtitle,
        onPress: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => settingsPage),
        ),
      );
    }

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 40),
                  child: Column(
                    spacing: 16,
                    children: [
                      FTileGroup(
                        label: Text('my_vault'.tr()),
                        children: [
                          buildSettingsTile(
                            prefix: LucideIcons.refreshCcw,
                            suffix: LucideIcons.chevronRight,
                            subtitle: buildStatusSubtitle(),
                            settingsPage: const SyncSettingsPage(),
                          ),
                          buildSettingsTile(
                            prefix: LucideIcons.users,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const IdentitiesSettingsPage(),
                          ),
                          buildSettingsTile(
                            prefix: LucideIcons.keyRound,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const KeysSettingsPage(),
                          ),
                          buildSettingsTile(
                            prefix: LucideIcons.fingerprintPattern,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const KnownHostsSettingsPage(),
                          ),
                          buildSettingsTile(
                            prefix: LucideIcons.swatchBook,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const TerminalThemeSettingsPage(),
                          ),
                        ],
                      ),
                      FTileGroup(
                        label: Text('app'.tr()),
                        children: [
                          buildSettingsTile(
                            prefix: LucideIcons.palette,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const AppearanceSettingsPage(),
                          ),
                          buildSettingsTile(
                            prefix: LucideIcons.languages,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const I18nSettingsPage(),
                          ),
                          if (PlatformUtils.isDesktop)
                            buildSettingsTile(
                              prefix: LucideIcons.keyboard,
                              suffix: LucideIcons.chevronRight,
                              settingsPage: const ShortcutsSettingsPage(),
                            ),
                          buildSettingsTile(
                            prefix: LucideIcons.terminal,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const SshSftpSettingsPage(),
                          ),
                          buildSettingsTile(
                            prefix: LucideIcons.fileText,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const LogsSettingsPage(),
                          ),
                          if (developerMode.value)
                            buildSettingsTile(
                              variant: .destructive,
                              prefix: LucideIcons.hammer,
                              suffix: LucideIcons.chevronRight,
                              settingsPage: const DeveloperSettingsPage(),
                            ),
                        ],
                      ),

                      const SizedBox.shrink(),
                      FTileGroup(
                        children: [
                          buildSettingsTile(
                            prefix: LucideIcons.scale,
                            suffix: LucideIcons.chevronRight,
                            settingsPage: const LicenseSettingsPage(),
                          ),
                          FTile(
                            prefix: const Icon(SimpleIcons.github),
                            suffix: const Icon(LucideIcons.externalLink),
                            title: const Text('GitHub'),
                            onPress: () => Commons.launchGitHubUrl(),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: .only(top: 12),
                        child: VersionIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
