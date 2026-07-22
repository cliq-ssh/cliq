import 'package:cliq/modules/settings/model/settings_importer/app_settings.model.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/settings/ui/password_dialog.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/import_or_export_settings_view.dart';
import 'package:cliq/modules/settings/view/register_or_login_view.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/modules/vaults/provider/vault_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/entity_type.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:cliq_ui/hooks/use_breakpoint.export.dart' show useBreakpoint;
import 'package:cliq_ui/theme.export.dart' show CliqFontFamily;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';
import '../../../shared/model/router.model.dart';
import '../../../shared/utils/commons.dart';
import '../../../shared/utils/text_utils.dart';
import '../../vaults/provider/vault.provider.dart';

class SyncSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'sync',
  );

  const SyncSettingsPage({super.key});

  @override
  String get title => 'sync'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final api = ref.watch(syncProvider).api;

    final lastUpdated = useStore(.syncLastUpdated);

    final userVault = useState<DbId?>(null);
    final entitiesCount = useState<(int, int, int, int)?>(null);

    final syncIconController = useAnimationController(
      duration: const Duration(seconds: 1),
    );

    final breakpoint = useBreakpoint();

    useEffect(() {
      if (api == null) return;
      ref.read(vaultProvider.notifier).findOrCreateUserVault(api).then((vault) {
        userVault.value = vault.id;

        ref.read(vaultServiceProvider).countEntitiesInVault(vault.id).then((
          count,
        ) {
          entitiesCount.value = count;
        });
      });
      return null;
    }, [api, lastUpdated.value]);

    buildIconCount(EntityType type, int count) {
      final muted = context.theme.colors.mutedForeground;

      return Row(
        spacing: 4,
        children: [
          Icon(type.icon, size: 16, color: muted),
          Text(
            count.toString(),
            style: .new(
              fontFamily: CliqFontFamily.secondary.fontFamily,
              color: muted,
            ),
          ),
        ],
      );
    }

    buildLoggedOutItems() {
      return [
        FTile(
          prefix: Icon(LucideIcons.cloudSync),
          suffix: Icon(LucideIcons.chevronRight),
          title: Text('sync_setup_sync'.tr()),
          subtitle: Text('sync_setup_sync_subtitle'.tr(), overflow: .visible),
          onPress: () => Commons.showResponsiveDialog(
            (_) => RegisterOrLoginView(),
            context: context,
            dismissable: false,
          ),
        ),
      ];
    }

    buildLoggedInItems(CliqClient api) {
      return [
        FTile(
          prefix: FAvatar.raw(
            child: Text(api.selfUser.username.substring(0, 1).toUpperCase()),
          ),
          title: Text(api.selfUser.username),
          subtitle: Text(api.selfUser.email),
        ),
        FTile(
          prefix: RotationTransition(
            turns: syncIconController,
            child: Icon(LucideIcons.refreshCw),
          ),
          suffix: breakpoint < .md || entitiesCount.value == null
              ? SizedBox.shrink()
              : Row(
                  spacing: 12,
                  mainAxisSize: .min,
                  children: [
                    buildIconCount(.connection, entitiesCount.value!.$1),
                    buildIconCount(.identity, entitiesCount.value!.$2),
                    buildIconCount(.key, entitiesCount.value!.$3),
                    buildIconCount(.knownHost, entitiesCount.value!.$4),
                  ],
                ),
          title: Text('sync_now'.tr()),
          subtitle: Text(
            'sync_last_updated'.tr(
              args: [
                lastUpdated.value == null || lastUpdated.value == 0
                    ? 'n_a'.tr()
                    : DateTime.fromMillisecondsSinceEpoch(
                        lastUpdated.value!,
                        isUtc: true,
                      ).toIso8601String(),
              ],
            ),
            overflow: .visible,
          ),
          onPress: () async {
            syncIconController.forward(from: 0);
            final pulled = await ref.read(syncProvider.notifier).pullVault();
            Commons.showToast(
              (pulled ? 'sync_vault_pulling' : 'sync_vault_up_to_date').tr(),
            );
          },
        ),
        if (breakpoint < .md)
          FTile(
            title: Row(
              spacing: 12,
              mainAxisSize: .min,
              children: [
                buildIconCount(.connection, entitiesCount.value!.$1),
                buildIconCount(.identity, entitiesCount.value!.$2),
                buildIconCount(.key, entitiesCount.value!.$3),
                buildIconCount(.knownHost, entitiesCount.value!.$4),
              ],
            ),
          ),
        FTile(
          variant: .destructive,
          prefix: Icon(LucideIcons.logOut),
          title: Text('logout'.tr()),
          onPress: () {
            Commons.showConfirmationDialog(
              confirmButtonText: 'logout'.tr(),
              title: 'sync_logout_title'.tr(),
              onConfirm: () async {
                await ref.read(syncProvider.notifier).logout();
              },
              children: (context, _, _) =>
                  TextUtils.renderText(context, 'sync_logout_body'.tr()),
            );
          },
        ),
      ];
    }

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
                      children: api == null
                          ? buildLoggedOutItems()
                          : buildLoggedInItems(api),
                    ),
                    FTileGroup(
                      label: Text('sync_manual_import_export'.tr()),
                      children: [
                        .tile(
                          prefix: Icon(LucideIcons.download),
                          suffix: Icon(LucideIcons.folderOpen),
                          title: Text('sync_import_file'.tr()),
                          onPress: () async {
                            AppSettings? settings;

                            final file = await openFile(
                              acceptedTypeGroups: [
                                Commons.getSettingsGroup(context),
                              ],
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
                                  e.key == 'sync_import_error_encrypted') {
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
                                prefix: Icon(LucideIcons.fileX),
                              );
                              return;
                            }

                            if (!context.mounted) return;

                            Commons.showResponsiveDialog(
                              (_) => ImportOrExportSettingsView.import(
                                current: settings,
                              ),
                              context: context,
                            );
                          },
                        ),
                        .tile(
                          prefix: Icon(LucideIcons.upload),
                          suffix: Icon(LucideIcons.chevronRight),
                          title: Text('sync_export_file'.tr()),
                          onPress: () => Commons.showResponsiveDialog(
                            (_) => ImportOrExportSettingsView.export(),
                            context: context,
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
