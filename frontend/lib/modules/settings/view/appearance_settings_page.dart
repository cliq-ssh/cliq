import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/store.dart';
import '../../../shared/model/page_path.model.dart';
import '../model/desktop_navigation_position.model.dart';
import '../model/theme.model.dart';

class AppearanceSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'appearance',
  );

  const AppearanceSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final currentTheme = useStore(.theme);
    final themeMode = useStore(.themeMode);
    final navPosition = useStore(.desktopNavigationPosition);

    final navPositionController =
        useFRadioMultiValueNotifier<DesktopNavigationPosition>(
          value: navPosition.value,
        );

    final themeModeController = useFRadioMultiValueNotifier<ThemeMode>(
      value: themeMode.value,
    );

    buildThemeButton(CliqTheme t) {
      final bool isCurrentTheme = t == currentTheme.value;
      return GestureDetector(
        onTap: () => StoreKey.theme.write(t),
        child: Tooltip(
          message: t.name,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.getThemeWithMode(themeMode.value!).colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: isCurrentTheme
                  ? Icon(
                      LucideIcons.check,
                      color: t
                          .getThemeWithMode(themeMode.value!)
                          .colors
                          .primaryForeground,
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return CliqGridContainer(
      children: [
        CliqGridRow(
          children: [
            CliqGridColumn(
              sizes: {.sm: 12, .md: 8},
              child: Form(
                onChanged: () {
                  final themeMode = themeModeController.value.firstOrNull;
                  final navPosition = navPositionController.value.firstOrNull;

                  if (themeMode != null) {
                    StoreKey.themeMode.write(themeMode);
                  }
                  if (PlatformUtils.isDesktop && navPosition != null) {
                    StoreKey.desktopNavigationPosition.write(navPosition);
                  }
                },
                child: Column(
                  spacing: 20,
                  children: [
                    if (PlatformUtils.isDesktop)
                      FSelectTileGroup<DesktopNavigationPosition>(
                        control: .managed(controller: navPositionController),
                        label: const Text('Navigation Position'),
                        description: const Text(
                          'Select the position of the desktop navigation bar.',
                        ),
                        children: [
                          for (DesktopNavigationPosition position
                              in DesktopNavigationPosition.values) ...[
                            FSelectTile(
                              title: Text(position.getDisplayName(context)),
                              suffix: Icon(position.icon),
                              value: position,
                            ),
                          ],
                        ],
                      ),
                    FSelectTileGroup<ThemeMode>(
                      control: .managed(controller: themeModeController),
                      label: const Text('Theme Mode'),
                      description: const Text(
                        'Select the theme mode for the application.',
                      ),
                      children: [
                        FSelectTile(
                          title: const Text('System'),
                          suffix: PlatformUtils.isMobile
                              ? const Icon(LucideIcons.smartphone)
                              : const Icon(LucideIcons.monitor),
                          value: ThemeMode.system,
                        ),
                        FSelectTile(
                          title: const Text('Light'),
                          suffix: const Icon(LucideIcons.sun),
                          value: ThemeMode.light,
                        ),
                        FSelectTile(
                          title: const Text('Dark'),
                          suffix: const Icon(LucideIcons.moon),
                          value: ThemeMode.dark,
                        ),
                      ],
                    ),
                    Align(
                      alignment: .centerLeft,
                      child: FLabel(
                        axis: .vertical,
                        child: Text(
                          'Color Theme',
                          style: context.theme.typography.base.copyWith(
                            color: context.theme.colors.primary,
                            fontWeight: .bold,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: .start,
                            children: [
                              for (CliqTheme t in CliqTheme.values) ...[
                                buildThemeButton(t),
                              ],
                            ],
                          ),
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
    );
  }
}
