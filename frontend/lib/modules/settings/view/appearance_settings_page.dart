import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/store.dart';
import '../../../shared/model/page_path.model.dart';
import '../../../shared/ui/custom_toggle_tile.dart';
import '../model/theme.model.dart';

class AppearanceSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'appearance',
  );

  const AppearanceSettingsPage({super.key});

  @override
  String get title => 'appearance'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final currentTheme = useStore(.theme);
    final themeMode = useStore(.themeMode);
    final applyTerminalThemeColorToNavigation = useStore(
      .applyTerminalThemeColorToNavigation,
    );

    getThemeModeDisplayName(ThemeMode mode) {
      return switch (mode) {
        ThemeMode.system => 'theme_mode_system'.tr(),
        ThemeMode.light => 'theme_mode_light'.tr(),
        ThemeMode.dark => 'theme_mode_dark'.tr(),
      };
    }

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Column(
                  spacing: 20,
                  children: [
                    FTileGroup(
                      children: [
                        FSelectMenuTile<ThemeMode>(
                          title: Text('appearance_theme_mode'.tr()),
                          prefix: const Icon(LucideIcons.sunMoon),
                          subtitle: Text('appearance_theme_mode_subtitle'.tr()),
                          selectControl: .managedRadio(
                            initial: themeMode.value,
                            onChange: (value) =>
                                StoreKey.themeMode.write(value.first),
                          ),
                          detailsBuilder: (context, value, _) {
                            if (value.isEmpty) return SizedBox.shrink();
                            return Text(getThemeModeDisplayName(value.first));
                          },
                          menu: [
                            for (ThemeMode mode in ThemeMode.values) ...[
                              .tile(
                                title: Text(getThemeModeDisplayName(mode)),
                                value: mode,
                              ),
                            ],
                          ],
                        ),
                        FSelectMenuTile<CliqTheme>(
                          title: Text('appearance_color_theme'.tr()),
                          prefix: const Icon(LucideIcons.palette),
                          subtitle: Text(
                            'appearance_color_theme_subtitle'.tr(),
                          ),
                          selectControl: .managedRadio(
                            initial: currentTheme.value,
                            onChange: (value) =>
                                StoreKey.theme.write(value.first),
                          ),
                          detailsBuilder: (context, value, _) {
                            if (value.isEmpty) return SizedBox.shrink();
                            return Text(value.first.getDisplayName());
                          },
                          menu: [
                            for (CliqTheme t in CliqTheme.values) ...[
                              .tile(
                                title: Text(t.getDisplayName()),
                                suffix: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: .circle,
                                    color: t
                                        .getThemeWithMode(themeMode.value)
                                        .colors
                                        .primary,
                                  ),
                                ),
                                value: t,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    FTileGroup(
                      children: [
                        CustomToggleTile(
                          title:
                              'appearance_apply_terminal_theme_color_to_navigation',
                          subtitle:
                              'appearance_apply_terminal_theme_color_to_navigation_subtitle',
                          prefix: Icon(LucideIcons.paintBucket),
                          storeKey: .applyTerminalThemeColorToNavigation,
                          value: applyTerminalThemeColorToNavigation.value,
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
