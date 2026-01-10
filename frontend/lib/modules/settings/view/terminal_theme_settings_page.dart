import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/provider/terminal_colors.provider.dart';
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

class TerminalThemeSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'terminal-theme',
  );

  static const List<String> fonts = ['JetBrainsMono', 'SourceCodePro'];
  static const String sampleText =
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
      StoreKey.terminalTypography.readSync()?.fontFamily ?? fonts.first,
    );
    final selectedFontSize = useState<double>(
      StoreKey.terminalTypography.readSync()?.fontSize ?? 16,
    );
    final selectedColors = useState<CustomTerminalTheme>(
      terminalThemes.effectiveActiveDefaultTheme,
    );

    // init controller
    useEffect(() {
      terminalController.value = TerminalController(
        colors: selectedColors.value.toTerminalColorTheme(),
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
      StoreKey.terminalTypography.write(typography);
      return null;
    }, [selectedFontFamily.value, selectedFontSize.value]);

    // update colors on theme change
    useEffect(() {
      if (terminalController.value == null) return null;
      terminalController.value!.colors = selectedColors.value
          .toTerminalColorTheme();
      StoreKey.terminalThemeName.write(selectedColors.value.name);
      return null;
    }, [selectedColors.value]);

    buildTerminalThemeCard(CustomTerminalTheme theme) {
      buildColor(Color color) {
        return Container(width: 8, height: 16, color: color);
      }

      return GestureDetector(
        onTap: () => selectedColors.value = theme,
        child: FCard(
          title: Row(
            spacing: 16,
            mainAxisAlignment: .spaceBetween,
            children: [
              Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      theme.redColor,
                      theme.greenColor,
                      theme.yellowColor,
                      theme.blueColor,
                      theme.purpleColor,
                      theme.cyanColor,
                      theme.whiteColor,
                    ].map(buildColor).toList(),
                  ),
                  Row(
                    children: [
                      theme.brightRedColor,
                      theme.brightGreenColor,
                      theme.brightYellowColor,
                      theme.brightBlueColor,
                      theme.brightPurpleColor,
                      theme.brightCyanColor,
                      theme.brightWhiteColor,
                    ].map(buildColor).toList(),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(theme.name),
                  Text(
                    'built-in',
                    style: context.theme.typography.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                      fontWeight: .normal,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (selectedColors.value == theme) Icon(LucideIcons.check),
            ],
          ),
        ),
      );
    }

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
                      // draw container with full width and height 200
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
                              terminalController.value!.feed(sampleText);
                            });
                            return TerminalView(
                              controller: terminalController.value!,
                              readOnly: true,
                            );
                          },
                        ),
                      ),
                    FSlider(
                      control: .managedContinuous(
                        initial: FSliderValue(
                          min: 0,
                          max: (selectedFontSize.value - 4) / 48,
                        ),
                      ),
                      label: Text('Font Size'),
                      tooltipBuilder: (_, value) {
                        final fontSize = (value * 48).round() + 4;
                        return Text('$fontSize');
                      },
                      onEnd: (value) {
                        final fontSize = (value.max * 48).round() + 4;
                        selectedFontSize.value = fontSize.toDouble();
                      },
                      marks: [
                        for (var i = 0; i <= 12; i++)
                          FSliderMark(
                            value: i / 12,
                            label: ((i * 4) + 4) % 8 != 0
                                ? Text('${(i * 4) + 4}')
                                : null,
                            tick: ((i * 4) + 4) % 8 == 0,
                          ),
                      ],
                    ),
                    FSelect<String>.rich(
                      control: .managed(
                        initial: selectedFontFamily.value,
                        onChange: (selected) {
                          if (selected != null) {
                            selectedFontFamily.value = selected;
                          }
                        },
                      ),
                      label: Text('Font Family'),
                      hint: selectedFontFamily.value,
                      format: (s) => s,
                      children: [
                        for (final font in fonts)
                          FSelectItem(
                            title: Text(
                              font,
                              style: TextStyle(
                                fontFamily: font,
                                fontWeight: .normal,
                              ),
                            ),
                            value: font,
                          ),
                      ],
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
                        buildTerminalThemeCard(defaultTerminalColorTheme),
                        for (final theme in terminalThemes.entities)
                          buildTerminalThemeCard(theme),
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
