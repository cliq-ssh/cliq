import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/settings/view/i18n_settings_page.dart';
import 'package:cliq/modules/settings/view/identities_settings_page.dart';
import 'package:cliq/modules/settings/view/keys_settings_page.dart';
import 'package:cliq/modules/settings/view/known_hosts_settings.dart';
import 'package:cliq/modules/settings/view/shortcuts_settings_page.dart';
import 'package:cliq/modules/settings/view/ssh_sftp_settings_page.dart';
import 'package:cliq/modules/settings/view/sync_settings_page.dart';
import 'package:cliq/modules/settings/view/terminal_theme_settings_page.dart';
import 'package:cliq/shared/extensions/router.extension.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_icons/simple_icons.dart';

import 'appearance_settings_page.dart';
import 'developer_settings_page.dart';
import 'license_page.dart';
import '../../../shared/model/page_path.model.dart';

class SettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/settings');

  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncProvider);

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                child: Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 40),
                  child: Column(
                    spacing: 16,
                    children: [
                      FTileGroup(
                        label: Text('my_vault'.tr()),
                        children: [
                          FTile(
                            prefix: Icon(LucideIcons.refreshCcw),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('sync'.tr()),
                            subtitle: sync.isConnected
                                ? Text('sync_last_date').tr(
                                    args: [
                                      sync.lastSync?.toIso8601String() ?? 'n_a',
                                    ],
                                  )
                                : Text('sync_not_connected'.tr()),
                            onPress: () => context.pushPath(
                              SyncSettingsPage.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: Icon(LucideIcons.users),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('identities'.tr()),
                            onPress: () => context.pushPath(
                              IdentitiesSettingsPage.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: Icon(LucideIcons.keyRound),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('keys'.tr()),
                            onPress: () => context.pushPath(
                              KeysSettingsPage.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: Icon(LucideIcons.fingerprintPattern),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('known_hosts'.tr()),
                            onPress: () => context.pushPath(
                              KnownHostsSettingsPage.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: Icon(LucideIcons.clock),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('history'.tr()),
                            onPress: null,
                          ),
                          FTile(
                            prefix: Icon(LucideIcons.swatchBook),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('terminal_themes'.tr()),
                            onPress: () => context.pushPath(
                              TerminalThemeSettingsPage.pagePath.build(),
                            ),
                          ),
                        ],
                      ),
                      FTileGroup(
                        label: Text('app'.tr()),
                        children: [
                          FTile(
                            prefix: Icon(LucideIcons.palette),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('appearance'.tr()),
                            onPress: () => context.pushPath(
                              AppearanceSettingsPage.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: Icon(LucideIcons.globe),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('language'.tr()),
                            onPress: () => context.pushPath(
                              I18nSettingsPage.pagePath.build(),
                            ),
                          ),
                          if (PlatformUtils.isDesktop)
                            FTile(
                              prefix: Icon(LucideIcons.keyboard),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('shortcuts'.tr()),
                              onPress: () => context.pushPath(
                                ShortcutsSettingsPage.pagePath.build(),
                              ),
                            ),
                          FTile(
                            prefix: Icon(LucideIcons.terminal),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('ssh_sftp'.tr()),
                            onPress: () => context.pushPath(
                              SshSftpSettingsPage.pagePath.build(),
                            ),
                          ),
                          if (kDebugMode)
                            FTile(
                              prefix: Icon(LucideIcons.hammer),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('developer'.tr()),
                              onPress: () => context.pushPath(
                                DeveloperSettingsPage.pagePath.build(),
                              ),
                            ),
                        ],
                      ),

                      SizedBox.shrink(),
                      FTileGroup(
                        children: [
                          FTile(
                            prefix: Icon(LucideIcons.scale),
                            suffix: Icon(LucideIcons.chevronRight),
                            title: Text('licenses'.tr()),
                            onPress: () => context.pushPath(
                              LicenseSettingsPage.pagePath.build(),
                            ),
                          ),
                          FTile(
                            prefix: Icon(SimpleIcons.github),
                            suffix: Icon(LucideIcons.externalLink),
                            title: Text('GitHub'),
                            onPress: () => Commons.launchGitHubUrl(),
                          ),
                        ],
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
