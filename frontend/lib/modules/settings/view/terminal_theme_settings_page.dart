import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart' hide CliqTheme;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:system_fonts/system_fonts.dart';

import '../../../routing/model/page_path.model.dart';

class TerminalThemeSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'terminal-theme',
  );

  static const List<String> fonts = ['JetBrainsMono', 'SourceCodePro'];
  static const String sampleText = "Lorem ipsum sit dolor amet";

  const TerminalThemeSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final terminalController = useState<TerminalController?>(null);

    final systemFonts = useState<List<String>>([]);
    final selectedFontFamily = useState<String>('SourceCodePro');

    useEffect(() {
      terminalController.value = TerminalController(rows: 40, cols: 80);
      // wait till initState of TerminalView is done
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sampleText.split('\n').forEach((line) {
          terminalController.value?.feed(line);
        });
      });
      return () => terminalController.value?.dispose();
    }, []);

    useEffect(() {
      SystemFonts().loadAllFonts().then((f) => systemFonts.value = f);
      return null;
    }, []);

    return CliqGridContainer(
      children: [
        CliqGridRow(
          children: [
            CliqGridColumn(
              sizes: {.sm: 12, .md: 8},
              child: Column(
                spacing: 20,
                children: [
                  if (terminalController.value != null)
                    // draw container with full width and height 200
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const .all(8),
                      color: TerminalColorThemes.darcula.backgroundColor,
                      child: TerminalView(
                        controller: terminalController.value!,
                        typography: TerminalTypography(
                          fontFamily: selectedFontFamily.value,
                          fontSize: 16,
                        ),
                        colors: TerminalColorThemes.darcula,
                      ),
                    ),
                  FSelect<String>.rich(
                    control: .managed(
                      onChange: (selected) {
                        if (selected != null) {
                          selectedFontFamily.value = selected;
                        }
                      },
                    ),
                    hint: 'Font Family',
                    format: (s) => s,
                    contentDivider: .full,
                    children: [
                      FSelectSection(
                        label: const Text('Bundled Fonts'),
                        items: {for (final item in fonts) item: item},
                      ),
                      FSelectSection(
                        label: const Text('System Fonts'),
                        items: {
                          for (final item in systemFonts.value) item: item,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
