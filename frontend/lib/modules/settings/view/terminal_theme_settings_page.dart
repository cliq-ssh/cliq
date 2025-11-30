import 'package:cliq/modules/settings/provider/theme.provider.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_ui/cliq_ui.dart' hide CliqTheme;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:system_fonts/system_fonts.dart';

import '../../../routing/model/page_path.model.dart';
import '../model/theme.model.dart';

class TerminalThemeSettingsPage extends AbstractSettingsPage {
  static const List<String> fonts = [
    'SourceCodePro'
  ];

  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'terminal-theme',
  );

  const TerminalThemeSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final currentTheme = theme.activeTheme;
    final systemFonts = useState<List<String>>([]);

    final themeModeController = useFRadioSelectGroupController<ThemeMode>(
      value: theme.themeMode,
    );

    return CliqGridContainer(
      children: [
        CliqGridRow(
          children: [
            CliqGridColumn(
              sizes: {.sm: 8},
              child: Column(
                spacing: 20,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [

                    ],
                  ),
                  FSelect<String>.searchBuilder(
                    hint: 'Font Family',
                    format: (s) => s,
                    filter: (query) async {
                      final systemFonts = await SystemFonts().loadAllFonts();
                      return [...systemFonts, ...fonts];
                    },
                    contentBuilder: (context, _, fruits) => [for (final fruit in fruits) FSelectItem(title: Text(fruit), value: fruit)],
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
