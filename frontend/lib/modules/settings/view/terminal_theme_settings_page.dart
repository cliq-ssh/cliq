import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/view/create_or_edit_terminal_theme_view.dart';
import 'package:cliq/shared/ui/terminal_font_family_select.dart';
import 'package:cliq/shared/ui/terminal_font_size_slider.dart';
import 'package:cliq/modules/settings/ui/terminal_theme_card.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:file_selector/file_selector.dart';
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
  String get title => 'Terminal Theme';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final terminalThemes = ref.watch(terminalThemeProvider);
    final terminalController = useState<TerminalController?>(null);
    final selectedFontFamily = useState<String>(
      StoreKey.defaultTerminalTypography.readSync()?.fontFamily ??
          TerminalFontFamilySelect.fonts.first,
    );
    final selectedFontSize = useState<int>(
      StoreKey.defaultTerminalTypography.readSync()!.fontSize,
    );
    final selectedThemeId = useState<int>(
      StoreKey.defaultTerminalThemeId.readSync()!,
    );

    getSelectedTheme() => terminalThemes.findById(selectedThemeId.value)!;

    // init controller
    useEffect(() {
      terminalController.value = TerminalController(
        theme: getSelectedTheme().toTerminalTheme(),
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
      terminalController.value!.theme = getSelectedTheme().toTerminalTheme();
      StoreKey.defaultTerminalThemeId.write(selectedThemeId.value);
      return null;
    }, [selectedThemeId.value]);

    create() => Commons.showResponsiveDialog(
      (_) => CreateOrEditTerminalThemeView.create(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 60),
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Column(
                  spacing: 20,
                  children: [
                    if (terminalController.value != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        padding: const .all(8),
                        color: getSelectedTheme().backgroundColor,
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
                    FLabel(
                      label: Row(
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .end,
                        children: [
                          Text('Theme'),
                          Row(
                            children: [
                              FButton(
                                variant: .ghost,
                                prefix: Icon(LucideIcons.plus),
                                onPress: create,
                                child: Text('Add Theme'),
                              ),
                              FButton(
                                variant: .ghost,
                                prefix: Icon(LucideIcons.folderOpen),
                                onPress: () async {
                                  final error = await ref
                                      .read(terminalThemeProvider.notifier)
                                      .tryImportCustomTerminalTheme(
                                        await openFile(
                                          acceptedTypeGroups: [
                                            Commons.customTerminalThemeGroup,
                                          ],
                                        ),
                                      );

                                  if (!context.mounted) return;
                                  if (error != null) {
                                    showFToast(
                                      context: context,
                                      icon: Icon(LucideIcons.circleX),
                                      title: Text('Failed to import theme'),
                                      description: Text(error),
                                    );
                                    return;
                                  }
                                  showFToast(
                                    context: context,
                                    icon: Icon(LucideIcons.circleCheck),
                                    title: Text('Theme imported successfully'),
                                  );
                                },
                                child: Text('Import'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      axis: .vertical,
                      child: Column(
                        spacing: 12,
                        children: [
                          for (final theme in [
                            defaultTerminalColorTheme,
                            ...terminalThemes.entities,
                          ])
                            TerminalThemeCard(
                              onTap: () => selectedThemeId.value = theme.id,
                              isSelected: selectedThemeId.value == theme.id,
                              theme: theme,
                              onEdit: () {
                                if (selectedThemeId.value == theme.id) {
                                  selectedThemeId.value = theme.id;
                                }
                              },
                              onDelete: () {
                                if (selectedThemeId.value == theme.id) {
                                  selectedThemeId.value =
                                      defaultTerminalColorTheme.id;
                                }
                              },
                            ),
                        ],
                      ),
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
