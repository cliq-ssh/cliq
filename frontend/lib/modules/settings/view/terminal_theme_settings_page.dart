import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/shared/ui/terminal_font_family_select.dart';
import 'package:cliq/shared/ui/terminal_font_size_slider.dart';
import 'package:cliq/modules/settings/ui/terminal_theme_card.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';
import '../provider/terminal_theme.provider.dart';

class TerminalThemeSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'terminal-theme',
  );

  static const String sampleInput =
      "\x1b[31mLorem\x1b[0m "
      "\x1b[32mipsum\x1b[0m "
      "\x1b[33mdolor\x1b[0m "
      "\x1b[34msit\x1b[0m "
      "\x1b[35mamet\x1b[0m "
      "\x1b[36mconsectetur\x1b[0m "
      "\x1b[37madipiscing\x1b[0m "
      "\x1b[30melit\x1b[0m\n"
      "\x1b7"
      "\r"
      "\x1b[1B"
      "\x1b[41m   \x1b[0m"
      "\x1b[42m   \x1b[0m"
      "\x1b[43m   \x1b[0m"
      "\x1b[44m   \x1b[0m"
      "\x1b[45m   \x1b[0m"
      "\x1b[46m   \x1b[0m"
      "\x1b[47m   \x1b[0m"
      "\x1b8"
      "\x1b[2B"
      "\r"
      "\x1b[101m   \x1b[0m"
      "\x1b[102m   \x1b[0m"
      "\x1b[103m   \x1b[0m"
      "\x1b[104m   \x1b[0m"
      "\x1b[105m   \x1b[0m"
      "\x1b[106m   \x1b[0m"
      "\x1b[107m   \x1b[0m\n";

  const TerminalThemeSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final terminalThemes = ref.watch(terminalThemeProvider);
    final terminalController = useState<TerminalController?>(null);
    final selectedFontFamily = useState<String>(
      StoreKey.defaultTerminalTypography.readSync()?.fontFamily ??
          TerminalFontFamilySelect.fonts.first,
    );
    final selectedFontSize = useState<int>(
      StoreKey.defaultTerminalTypography.readSync()?.fontSize ?? 16,
    );
    final selectedColors = useState<CustomTerminalTheme>(
      terminalThemes.effectiveActiveDefaultTheme,
    );

    // init controller
    useEffect(() {
      terminalController.value = TerminalController(
        theme: selectedColors.value.toTerminalTheme(),
        typography: TerminalTypography(
          fontFamily: selectedFontFamily.value,
          fontSize: selectedFontSize.value,
        ),
      );
      terminalController.value?.setAutoWrapMode(true);
      return () => terminalController.value?.dispose();
    }, []);

    // update typography on font family change
    useEffect(() {
      if (terminalController.value == null) return null;
      final typography = TerminalTypography(
        fontFamily: selectedFontFamily.value,
        fontSize: selectedFontSize.value,
      );
      terminalController.value!.typography = typography;
      StoreKey.defaultTerminalTypography.write(typography);
      return null;
    }, [selectedFontFamily.value, selectedFontSize.value]);

    // update colors on theme change
    useEffect(() {
      if (terminalController.value == null) return null;
      terminalController.value!.theme = selectedColors.value.toTerminalTheme();
      StoreKey.defaultTerminalThemeId.write(selectedColors.value.id);
      return null;
    }, [selectedColors.value]);

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                sizes: {.sm: 12, .md: 8},
                child: Column(
                  spacing: 20,
                  children: [
                    if (terminalController.value != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        padding: const .all(8),
                        color: selectedColors.value.backgroundColor,
                        child: LayoutBuilder(
                          builder: (_, constraints) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              terminalController.value!.fitResize(
                                constraints.biggest,
                              );
                              terminalController.value!.activeBuffer.clear();
                              terminalController.value!.feed(sampleInput);
                            });
                            return TerminalView(
                              controller: terminalController.value!,
                              readOnly: true,
                            );
                          },
                        ),
                      ),
                    TerminalFontSizeSlider(
                      selectedFontSize: selectedFontSize.value,
                      onEnd: (value) => selectedFontSize.value = value,
                    ),
                    TerminalFontFamilySelect(
                      selectedFontFamily: selectedFontFamily.value,
                      onChange: (selected) =>
                          selectedFontFamily.value = selected,
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text('Theme'),
                        FButton(
                          style: FButtonStyle.ghost(),
                          prefix: Icon(LucideIcons.folderOpen),
                          onPress: null,
                          child: Text('Import'),
                        ),
                      ],
                    ),
                    Column(
                      spacing: 12,
                      children: [
                        for (final theme in [
                          defaultTerminalColorTheme,
                          ...terminalThemes.entities,
                        ])
                          TerminalThemeCard(
                            onTap: () => selectedColors.value = theme,
                            isSelected: selectedColors.value.id == theme.id,
                            theme: theme,
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
