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
      body: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(
                    spacing: 16,
                    children: [
                      CliqTypography('SSH', size: context.theme.typography.h2),
                      CliqTile(
                        leading: Icon(LucideIcons.refreshCcw),
                        trailing: Icon(LucideIcons.chevronRight),
                        title: Text('Sync'),
                        subtitle: Text('Manage synchronization settings'),
                        onTap: () =>
                            context.pushPath(SyncSettingsPage.pagePath.build()),
                      ),
                      CliqTile(
                        leading: Icon(LucideIcons.keyRound),
                        trailing: Icon(LucideIcons.chevronRight),
                        title: Text('Identities'),
                        subtitle: Text('Manage your SSH identities'),
                        onTap: () => context.pushPath(
                          IdentitiesSettingsPage.pagePath.build(),
                        ),
                      ),
                      CliqTypography('App', size: context.theme.typography.h2),
                      CliqTile(
                        leading: Icon(LucideIcons.palette),
                        trailing: Icon(LucideIcons.chevronRight),
                        title: Text('Theme'),
                        subtitle: Text('Customize the application theme'),
                        onTap: () => context.pushPath(
                          ThemeSettingsPage.pagePath.build(),
                        ),
                      ),
                      if (kDebugMode)
                        CliqTile(
                          leading: Icon(LucideIcons.bug),
                          trailing: Icon(LucideIcons.chevronRight),
                          title: Text('Debug'),
                          subtitle: Text('Debugging options and tools'),
                          onTap: () => context.pushPath(
                            DebugSettingsPage.pagePath.build(),
                          ),
                        ),

                      // TODO: implement tile group
                      SizedBox.shrink(),
                      Column(
                        children: [
                          CliqTile(
                            leading: Icon(LucideIcons.scale),
                            trailing: Icon(LucideIcons.chevronRight),
                            title: Text('Licenses'),
                            onTap: () => context.pushPath(
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
    );
  }
}
