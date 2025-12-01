import 'package:cliq/modules/settings/provider/theme.provider.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_ui/cliq_ui.dart' hide CliqTheme;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../routing/model/page_path.model.dart';
import '../model/theme.model.dart';

class ThemeSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'theme',
  );

  const ThemeSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final currentTheme = theme.activeTheme;

    final themeModeController = useFRadioSelectGroupController<ThemeMode>(
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
              sizes: {.sm: 8},
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
                    FSelectMenuTile<ThemeMode>(
                      selectController: themeModeController,
                      title: Text('Theme Mode'),
                      details: ListenableBuilder(
                        listenable: themeModeController,
                        builder: (context, _) {
                          return Text(
                            switch (themeModeController.value.firstOrNull) {
                              ThemeMode.system => 'System',
                              ThemeMode.light => 'Light',
                              ThemeMode.dark => 'Dark',
                              null => '',
                            },
                          );
                        },
                      ),
                      autoHide: true,
                      menu: [
                        FSelectTile(
                          title: Text('System'),
                          value: ThemeMode.system,
                        ),
                        FSelectTile(
                          title: Text('Light'),
                          value: ThemeMode.light,
                        ),
                        FSelectTile(title: Text('Dark'), value: ThemeMode.dark),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (CliqTheme t in CliqTheme.values) ...[
                          buildThemeButton(t),
                        ],
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
