import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/settings/ui/password_dialog.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/import_or_export_settings_view.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';
import '../../../shared/model/router.model.dart';
import '../../../shared/utils/commons.dart';

class SyncSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'sync',
  );

  const SyncSettingsPage({super.key});

  @override
  String get title => 'Sync';

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
                      children: [
                        FTile(
                          prefix: Icon(LucideIcons.download),
                          suffix: Icon(LucideIcons.folderOpen),
                          title: Text('Import from File'),
                          onPress: () async {
                            AppSettings? settings;

                            final file = await openFile(
                              acceptedTypeGroups: [Commons.settingsGroup],
                            );

                            read({String? password}) async {
                              return await ref
                                  .read(syncProvider.notifier)
                                  .tryParseSettings(file, password: password);
                            }

                            try {
                              settings = await read();
                            } catch (e) {
                              if (e is LocalizedException &&
                                  e.key ==
                                      'settings.import.error.encryptedFile') {
                                // prompt password input
                                final password = await showFDialog(
                                  context:
                                      Router.rootNavigatorKey.currentContext ??
                                      context,
                                  builder: (context, style, animation) =>
                                      PasswordDialog(
                                        style: style,
                                        animation: animation,
                                      ),
                                );
                                settings = await read(password: password);
                              }
                            }

                            if (settings == null) return;
                            if (settings.isEmpty) {
                              Commons.showToast(
                                'settings.import.error.invalidOrEmptyFile',
                                prefix: Icon(LucideIcons.fileX, size: 20),
                              );
                              return;
                            }

                            Commons.showResponsiveDialog(
                              (_) => ImportOrExportSettingsView.import(
                                current: settings,
                              ),
                            );
                          },
                        ),
                        FTile(
                          prefix: Icon(LucideIcons.upload),
                          suffix: Icon(LucideIcons.chevronRight),
                          title: Text('Export to File'),
                          onPress: () => Commons.showResponsiveDialog(
                            (_) => ImportOrExportSettingsView.export(),
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
