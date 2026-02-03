import 'package:cliq/modules/settings/view/identities_settings_page.dart';
import 'package:cliq/modules/settings/view/keys_settings_page.dart';
import 'package:cliq/modules/settings/view/known_hosts_settings.dart';
import 'package:cliq/modules/settings/view/terminal_theme_settings_page.dart';
import 'package:cliq/shared/extensions/router.extension.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'appearance_settings_page.dart';
import 'debug_settings_page.dart';
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
    return FScaffold(
      header: FHeader.nested(
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: SingleChildScrollView(
        child: CliqGridContainer(
          children: [
            CliqGridRow(
              alignment: WrapAlignment.center,
              children: [
                CliqGridColumn(
                  sizes: {.sm: 12, .md: 8},
                  child: Padding(
                    padding: EdgeInsets.only(top: 80, bottom: 40),
                    child: Column(
                      spacing: 16,
                      children: [
                        FTileGroup(
                          label: Text('My Vault'),
                          children: [
                            FTile(
                              prefix: Icon(LucideIcons.refreshCcw),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('Sync'),
                              subtitle: Text('Not connected'),
                              onPress: null,
                            ),
                            FTile(
                              prefix: Icon(LucideIcons.users),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('Identities'),
                              onPress: () => context.pushPath(
                                IdentitiesSettingsPage.pagePath.build(),
                              ),
                            ),
                            FTile(
                              prefix: Icon(LucideIcons.keyRound),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('Keys'),
                              onPress: () => context.pushPath(
                                KeysSettingsPage.pagePath.build(),
                              ),
                            ),
                            FTile(
                              prefix: Icon(LucideIcons.fingerprintPattern),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('Known Hosts'),
                              onPress: () => context.pushPath(
                                KnownHostsSettingsPage.pagePath.build(),
                              ),
                            ),
                            FTile(
                              prefix: Icon(LucideIcons.clock),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('History'),
                              onPress: null,
                            ),
                            FTile(
                              prefix: Icon(LucideIcons.squareTerminal),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('Terminal Theme'),
                              onPress: () => context.pushPath(
                                TerminalThemeSettingsPage.pagePath.build(),
                              ),
                            ),
                          ],
                        ),
                        FTileGroup(
                          label: Text('App'),
                          children: [
                            FTile(
                              prefix: Icon(LucideIcons.palette),
                              suffix: Icon(LucideIcons.chevronRight),
                              title: Text('Appearance'),
                              onPress: () => context.pushPath(
                                AppearanceSettingsPage.pagePath.build(),
                              ),
                            ),
                            if (kDebugMode)
                              FTile(
                                prefix: Icon(LucideIcons.bug),
                                suffix: Icon(LucideIcons.chevronRight),
                                title: Text('Debug'),
                                onPress: () => context.pushPath(
                                  DebugSettingsPage.pagePath.build(),
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
                              title: Text('Licenses'),
                              onPress: () => context.pushPath(
                                LicenseSettingsPage.pagePath.build(),
                              ),
                            ),
                            FTile(
                              prefix: Icon(LucideIcons.github),
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
      ),
    );
  }
}
