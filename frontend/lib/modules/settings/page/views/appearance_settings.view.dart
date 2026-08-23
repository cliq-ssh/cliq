import 'package:cliq/modules/settings/model/app_theme/app_theme.model.dart';
import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/custom_toggle_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const AppearanceSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'appearance',
  );

  @override
  String get title => 'appearance'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final currentBaseColors = useStore(.appearanceBaseColors);
    final currentPrimaryColor = useStore(.appearancePrimaryColor);

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

    buildAppearanceSelect<T extends PresetColors>({
      required String title,
      required IconData prefix,
      required String subtitle,
      required T initial,
      required StoreKey<T> key,
      required List<T> all,
      required Color Function(T) getPreviewColor,
    }) {
      return FSelectMenuTile<T>(
        title: Text(title),
        prefix: Icon(prefix),
        subtitle: Text(subtitle),
        selectControl: .managedRadio(
          initial: initial,
          onChange: (value) => key.write(value.first),
        ),
        detailsBuilder: (context, value, _) {
          if (value.isEmpty) return const SizedBox.shrink();
          return Text(value.first.getDisplayName(context));
        },
        maxHeight: 300,
        menu: [
          for (T t in all) ...[
            .tile(
              title: Text(t.getDisplayName(context)),
              suffix: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: .circle,
                  color: getPreviewColor(t),
                  border: Border.all(
                    color: context.theme.colors.border,
                    width: 1,
                  ),
                ),
              ),
              value: t,
            ),
          ],
        ],
      );
    }

    return Column(
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
                onChange: (value) => StoreKey.themeMode.write(value.first),
              ),
              detailsBuilder: (context, value, _) {
                if (value.isEmpty) return const SizedBox.shrink();
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
          ],
        ),
        FTileGroup(
          children: [
            buildAppearanceSelect<PresetBaseColors>(
              title: 'appearance_base_colors'.tr(),
              prefix: LucideIcons.paintBucket,
              subtitle: 'appearance_base_colors_subtitle'.tr(),
              initial: currentBaseColors.value,
              key: .appearanceBaseColors,
              all: PresetBaseColors.values,
              getPreviewColor: (baseColors) =>
                  Color(baseColors.getByThemeMode(themeMode.value).card),
            ),
            buildAppearanceSelect<PresetPrimaryColor>(
              title: 'appearance_primary_color'.tr(),
              prefix: LucideIcons.paintbrush,
              subtitle: 'appearance_primary_color_subtitle'.tr(),
              initial: currentPrimaryColor.value,
              key: .appearancePrimaryColor,
              all: PresetPrimaryColor.values,
              getPreviewColor: (primaryColor) =>
                  Color(primaryColor.getByThemeMode(themeMode.value).primary),
            ),
          ],
        ),
        FTileGroup(
          children: [
            CustomToggleTile(
              title: 'appearance_apply_terminal_theme_color_to_navigation',
              subtitle: 'appearance_apply_terminal_theme_color_to_navigation_subtitle',
              prefix: const Icon(LucideIcons.paintBucket),
              storeKey: .applyTerminalThemeColorToNavigation,
              value: applyTerminalThemeColorToNavigation.value,
            ),
          ],
        ),
      ],
    );
  }
}
