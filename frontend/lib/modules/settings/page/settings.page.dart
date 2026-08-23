import 'package:cliq/modules/settings/page/views/appearance_settings.view.dart';
import 'package:cliq/modules/settings/page/views/developer_settings.view.dart';
import 'package:cliq/modules/settings/page/views/i18n_settings.view.dart';
import 'package:cliq/modules/settings/page/views/identities_settings.view.dart';
import 'package:cliq/modules/settings/page/views/keys_settings.view.dart';
import 'package:cliq/modules/settings/page/views/known_hosts_settings.view.dart';
import 'package:cliq/modules/settings/page/views/licenses.view.dart';
import 'package:cliq/modules/settings/page/views/shortcuts_settings.view.dart';
import 'package:cliq/modules/settings/page/views/ssh_sftp_settings.view.dart';
import 'package:cliq/modules/settings/page/views/sync_settings.view.dart';
import 'package:cliq/modules/settings/page/views/terminal_theme_settings.view.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/settings/ui/version_indicator.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/extensions/router.extension.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_icons/simple_icons.dart';

class const SettingsPage({super.key}) extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/settings');

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncProvider);
    final info = useMemoizedFuture(() => PackageInfo.fromPlatform(), []);

    final developerMode = useStore(.developerMode);
    final lastUpdated = useStore(.syncLastUpdated);

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
                          FTile(
                            prefix: const Icon(LucideIcons.refreshCcw),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('sync'.tr()),
                            subtitle: sync.isConnected
                                ? const Text('sync_last_updated').tr(
                                    args: [
                                      lastUpdated.value == null ||
                                              lastUpdated.value == 0
                                          ? 'n_a'.tr()
                                          : DateTime.fromMillisecondsSinceEpoch(
                                              lastUpdated.value!,
                                              isUtc: true,
                                            ).toIso8601String(),
                                    ],
                                  )
                                : Text('sync_not_connected'.tr()),
                            onPress: () => context.pushPath(
                              SyncSettingsView.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(LucideIcons.users),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('identities'.tr()),
                            onPress: () => context.pushPath(
                              IdentitiesSettingsView.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(LucideIcons.keyRound),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('keys'.tr()),
                            onPress: () => context.pushPath(
                              KeysSettingsView.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(LucideIcons.fingerprintPattern),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('known_hosts'.tr()),
                            onPress: () => context.pushPath(
                              KnownHostsSettingsView.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(LucideIcons.swatchBook),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('terminal_themes'.tr()),
                            onPress: () => context.pushPath(
                              TerminalThemeSettingsView.pagePath.build(),
                            ),
                          ),
                        ],
                      ),
                      FTileGroup(
                        label: Text('app'.tr()),
                        children: [
                          FTile(
                            prefix: const Icon(LucideIcons.palette),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('appearance'.tr()),
                            onPress: () => context.pushPath(
                              AppearanceSettingsView.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(LucideIcons.languages),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('language'.tr()),
                            onPress: () => context.pushPath(
                              I18nSettingsView.pagePath.build(),
                            ),
                          ),
                          if (PlatformUtils.isDesktop)
                            FTile(
                              prefix: const Icon(LucideIcons.keyboard),
                              suffix: const Icon(LucideIcons.chevronRight),
                              title: Text('shortcuts'.tr()),
                              onPress: () => context.pushPath(
                                ShortcutsSettingsView.pagePath.build(),
                              ),
                            ),
                          FTile(
                            prefix: const Icon(LucideIcons.terminal),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('ssh_sftp'.tr()),
                            onPress: () => context.pushPath(
                              SshSftpSettingsView.pagePath.build(),
                            ),
                          ),
                          if (developerMode.value)
                            FTile(
                              variant: .destructive,
                              prefix: const Icon(LucideIcons.hammer),
                              suffix: const Icon(LucideIcons.chevronRight),
                              title: Text('developer'.tr()),
                              onPress: () => context.pushPath(
                                DeveloperSettingsView.pagePath.build(),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox.shrink(),
                      FTileGroup(
                        children: [
                          FTile(
                            prefix: const Icon(LucideIcons.scale),
                            suffix: const Icon(LucideIcons.chevronRight),
                            title: Text('licenses'.tr()),
                            onPress: () => context.pushPath(
                              LicenseSettingsView.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(SimpleIcons.github),
                            suffix: const Icon(LucideIcons.externalLink),
                            title: const Text('GitHub'),
                            onPress: () => Commons.launchGitHubUrl(),
                          ),
                        ],
                      ),

                      info.on(
                        onData: (data) {
                          return Padding(
                            padding: const .only(top: 12),
                            child: VersionIndicator(packageInfo: data),
                          );
                        },
                        defaultValue: const SizedBox.shrink(),
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
