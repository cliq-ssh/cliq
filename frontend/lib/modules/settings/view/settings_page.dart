import 'package:cliq/modules/settings/view/identities_settings_page.dart';
import 'package:cliq/modules/settings/view/sync_settings_page.dart';
import 'package:cliq/modules/settings/view/theme_settings_page.dart';
import 'package:cliq/routing/router.extension.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/commons.dart';
import 'debug_settings_page.dart';
import 'license_page.dart';
import '../../../routing/page_path.dart';

class SettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/settings');

  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return CliqScaffold(
      safeAreaTop: true,
      extendBehindAppBar: true,
      header: CliqHeader(left: [Commons.backButton(context)]),
      body: SingleChildScrollView(
        child: CliqGridContainer(
          children: [
            CliqGridRow(
              children: [
                CliqGridColumn(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80, bottom: 40),
                    child: Column(
                      spacing: 16,
                      children: [
                        CliqTileGroup(
                          label: Text('SSH Settings'),
                          children: [
                            CliqTile(
                              leading: Icon(LucideIcons.refreshCcw),
                              trailing: Icon(LucideIcons.chevronRight),
                              title: Text('Sync'),
                              onPressed: () => context.pushPath(
                                SyncSettingsPage.pagePath.build(),
                              ),
                            ),
                            CliqTile(
                              leading: Icon(LucideIcons.keyRound),
                              trailing: Icon(LucideIcons.chevronRight),
                              title: Text('Identities'),
                              onPressed: () => context.pushPath(
                                IdentitiesSettingsPage.pagePath.build(),
                              ),
                            ),
                          ],
                        ),
                        CliqTileGroup(
                          label: Text('App'),
                          children: [
                            CliqTile(
                              leading: Icon(LucideIcons.palette),
                              trailing: Icon(LucideIcons.chevronRight),
                              title: Text('Theme'),
                              onPressed: () => context.pushPath(
                                ThemeSettingsPage.pagePath.build(),
                              ),
                            ),
                            if (kDebugMode)
                              CliqTile(
                                leading: Icon(LucideIcons.bug),
                                trailing: Icon(LucideIcons.chevronRight),
                                title: Text('Debug'),
                                onPressed: () => context.pushPath(
                                  DebugSettingsPage.pagePath.build(),
                                ),
                              ),
                          ],
                        ),

                        // TODO: implement tile group
                        SizedBox.shrink(),
                        CliqTileGroup(
                          children: [
                            CliqTile(
                              leading: Icon(LucideIcons.scale),
                              trailing: Icon(LucideIcons.chevronRight),
                              title: Text('Licenses'),
                              onPressed: () => context.pushPath(
                                LicenseSettingsPage.pagePath.build(),
                              ),
                            ),
                            CliqTile(
                              leading: Icon(LucideIcons.github),
                              trailing: Icon(LucideIcons.externalLink),
                              title: Text('GitHub'),
                            ),
                          ],
                        ),
                        CliqTypography('v0.0.0', size: typography.copyS),
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
