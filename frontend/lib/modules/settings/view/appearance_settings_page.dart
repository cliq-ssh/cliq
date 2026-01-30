import 'package:cliq/modules/settings/provider/theme.provider.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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
    final theme = ref.watch(themeProvider);
    final navPosition = useStore(.desktopNavigationPosition);
    final currentTheme = theme.activeTheme;

    final themeModeController = useFRadioMultiValueNotifier<ThemeMode>(
      value: theme.themeMode,
    );

    buildThemeButton(CliqTheme t) {
      final bool isCurrentTheme = t == currentTheme;
      return GestureDetector(
        onTap: () => ref.watch(themeProvider.notifier).setTheme(t),
        child: Tooltip(
          message: t.name,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.getThemeWithMode(theme.themeMode).colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: isCurrentTheme
                  ? Icon(
                      LucideIcons.check,
                      color: t
                          .getThemeWithMode(theme.themeMode)
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
                  if (themeModeController.value.firstOrNull != null) {
                    ref
                        .watch(themeProvider.notifier)
                        .setThemeMode(themeModeController.value.first);
                  }
                },
                child: Column(
                  spacing: 20,
                  children: [
                    FSelectTileGroup<ThemeMode>(
                      control: FMultiValueControl.managed(
                        initial: {theme.themeMode},
                      ),
                      label: const Text('Theme Mode'),
                      description: const Text(
                        'Select the theme mode for the application.',
                      ),
                      children: [
                        FSelectTile(
                          title: const Text('System'),
                          suffix: const Icon(LucideIcons.smartphone),
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
                        child: Text('Color Theme',
                            style: context.theme.typography.base.copyWith(
                              color: context.theme.colors.primary,
                              fontWeight: .bold
                            )
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
                    Column(
                      spacing: 12,
                      children: [
                        FSelectTileGroup<DesktopNavigationPosition>(
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
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Flexible(child: Text('Use terminal theme as navigation background')),
                            FSwitch(
                              value: true,
                              onChange: (value) {
                                // TODO
                              },
                            ),
                          ],
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
