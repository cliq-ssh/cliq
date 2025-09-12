import 'package:cliq/modules/settings/model/settings_module.dart';
import 'package:cliq/modules/settings/model/theme_module.dart';
import 'package:cliq/routing/router.extension.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/commons.dart';
import '../model/debug_module.dart';
import '../model/sync_module.dart';
import 'license_page.dart';
import '../../../routing/page_path.dart';

class SettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/settings');

  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<SettingsPage> {
  final List<(GlobalKey, SettingsModule)> _modules = [
    (GlobalKey(), SyncModule()),
    (GlobalKey(), ThemeModule()),
    if (kDebugMode) (GlobalKey(), DebugModule()),
  ];

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return CliqScaffold(
      safeAreaTop: true,
      extendBehindAppBar: true,
      header: CliqHeader(left: [Commons.backButton(context)]),
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          spacing: 8,
                          children: [
                            for (var (key, module) in _modules)
                              CliqChip(
                                onTap: () => Scrollable.ensureVisible(
                                  key.currentContext!,
                                  duration: const Duration(milliseconds: 500),
                                ),
                                title: Text(module.title),
                                leading: Icon(module.iconData),
                              ),
                          ],
                        ),
                      ),
                      for (var (key, module) in _modules)
                        CliqCard(
                          key: key,
                          title: Text(module.title),
                          subtitle: module.description != null
                              ? Text(module.description!)
                              : null,
                          child: module.build(context),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: CliqIconButton(
                          icon: Icon(LucideIcons.scale),
                          label: Text('Licenses'),
                          onPressed: () =>
                              context.pushPath(LicensePage.pagePath.build()),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: CliqIconButton(
                          icon: Icon(LucideIcons.github),
                          label: Text('GitHub'),
                        ),
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
