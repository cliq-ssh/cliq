import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/modules/settings/provider/terminal_theme_service.provider.dart';
import 'package:cliq/modules/settings/ui/color_scheme_browser_dialog.dart';
import 'package:cliq/modules/settings/ui/create_or_edit_terminal_theme_sheet.dart';
import 'package:cliq/modules/settings/ui/terminal_theme_card.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/terminal_font_family_select.dart';
import 'package:cliq/shared/ui/terminal_font_size_slider.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/hooks/use_breakpoint.export.dart' show useBreakpoint;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const TerminalThemeSettingsView({super.key})
    extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'terminal-theme',
  );

  static const String sampleInput =
      '$kSeqEscape[31mLorem$kSeqEscape[0m '
      '$kSeqEscape[32mipsum$kSeqEscape[0m '
      '$kSeqEscape[33mdolor$kSeqEscape[0m '
      '$kSeqEscape[34msit$kSeqEscape[0m '
      '$kSeqEscape[35mamet$kSeqEscape[0m '
      '$kSeqEscape[36mconsectetur$kSeqEscape[0m '
      '$kSeqEscape[37madipiscing$kSeqEscape[0m '
      '$kSeqEscape[30melit\x1b[0m\n'
      '${kSeqEscape}7'
      '\r'
      '$kSeqEscape[1B'
      '$kSeqEscape[41m   $kSeqEscape[0m'
      '$kSeqEscape[42m   $kSeqEscape[0m'
      '\x1b[43m   \x1b[0m'
      '\x1b[44m   \x1b[0m'
      '\x1b[45m   \x1b[0m'
      '\x1b[46m   \x1b[0m'
      '\x1b[47m   \x1b[0m'
      '\x1b8'
      '\x1b[2B'
      '\r'
      '\x1b[101m   \x1b[0m'
      '\x1b[102m   \x1b[0m'
      '\x1b[103m   \x1b[0m'
      '\x1b[104m   \x1b[0m'
      '\x1b[105m   \x1b[0m'
      '\x1b[106m   \x1b[0m'
      '\x1b[107m   \x1b[0m\n';

  @override
  String get title => 'terminal_themes'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final breakpoint = useBreakpoint();
    final popoverController = useFPopoverController();

    final terminalThemes = ref.watch(terminalThemeProvider);
    final connections = ref.watch(connectionProvider);

    final terminalController = useState<TerminalController?>(null);
    final selectedFontFamily = useState<String>(
      StoreKey.defaultTerminalTypography.readSync()?.fontFamily ??
          TerminalFontFamilySelect.fonts.first,
    );
    final selectedFontSize = useState<int>(
      StoreKey.defaultTerminalTypography.readSync()!.fontSize,
    );
    final selectedThemeId = useState<DbId>(
      StoreKey.defaultTerminalThemeId.readSync()!,
    );

    final subtitleStyle = context.theme.typography.body.xs.copyWith(
      color: context.theme.colors.mutedForeground,
      fontWeight: .normal,
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
      terminalController.value!.setTerminalTypography(typography);
      StoreKey.defaultTerminalTypography.write(typography);
      return null;
    }, [selectedFontFamily.value, selectedFontSize.value]);

    // update colors on theme change
    useEffect(() {
      if (terminalController.value == null) return null;
      terminalController.value!.setTerminalTheme(
        getSelectedTheme().toTerminalTheme(),
      );
      StoreKey.defaultTerminalThemeId.write(selectedThemeId.value);
      return null;
    }, [selectedThemeId.value]);

    create() => Commons.showResponsiveSheet(
      (_) => const CreateOrEditTerminalThemeSheet.create(),
      context: context,
    );

    openBrowser() async {
      await showFDialog(
        context: context,
        builder: (_, style, animation) => ColorSchemeBrowserDialog(
          style: style,
          animation: animation,
          onImport: (colorScheme) async {
            final terminalThemeService = ref.read(terminalThemeServiceProvider);

            final doesExist = await terminalThemeService.doesExist(
              colorScheme: colorScheme,
            );

            if (doesExist) {
              await Commons.showToast(
                'terminal_themes_already_exist'.tr(),
                prefix: const Icon(LucideIcons.messageCircleWarning),
              );
              return;
            }

            await terminalThemeService.createCustomTerminalTheme(colorScheme);
            await Commons.showToast(
              'terminal_themes_import_success'.tr(),
              prefix: const Icon(LucideIcons.circleCheck),
            );
          },
        ),
      );
    }

    importFile() async {
      final opened = await openFile(
        acceptedTypeGroups: [Commons.getCustomTerminalThemeGroup(context)],
      );
      if (opened == null) return;

      try {
        await ref
            .read(terminalThemeProvider.notifier)
            .tryImportCustomTerminalTheme(opened);
      } on LocalizedException catch (e) {
        await Commons.showLocalizedException(e);
        return;
      }
      if (!context.mounted) return;

      showFToast(
        context: context,
        icon: const Icon(LucideIcons.circleCheck),
        title: Text('terminal_themes_import_success'.tr()),
      );
    }

    getConnectionsWithOverrides() {
      hasThemeOverride(c) => c.terminalThemeOverride != null;
      hasTypographyOverride(c) => c.terminalTypographyOverride != null;

      final withOverrides = connections.entities
          .where((c) => hasThemeOverride(c) || hasTypographyOverride(c))
          .toList();
      return [
        for (final connection in withOverrides)
          FTile(
            prefix: ConnectionIcon.fromConnection(
              connection,
              borderRadius: 10,
              size: 16,
              padding: 8,
            ),
            suffix: FTooltip(
              tipBuilder: (_, _) =>
                  Text('terminal_themes_overrides_revert'.tr()),
              child: FButton.icon(
                onPress: () async {
                  await ref
                      .read(connectionProvider.notifier)
                      .resetOverrides(connection.id);
                },
                child: const Icon(LucideIcons.undo2),
              ),
            ),
            title: Text(connection.label),
            subtitle: Column(
              children: [
                if (hasThemeOverride(connection))
                  Row(
                    spacing: 4,
                    children: [
                      Icon(
                        LucideIcons.swatchBook,
                        size: subtitleStyle.fontSize,
                        color: subtitleStyle.color,
                      ),
                      Text(
                        connection.terminalThemeOverride!.name,
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                if (hasTypographyOverride(connection))
                  Row(
                    spacing: 4,
                    children: [
                      Icon(
                        LucideIcons.baseline,
                        size: subtitleStyle.fontSize,
                        color: subtitleStyle.color,
                      ),
                      Text(
                        '${connection.terminalTypographyOverride!.fontFamily}, ${connection.terminalTypographyOverride!.fontSize}px',
                        style: subtitleStyle,
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ];
    }

    return Column(
      spacing: 20,
      children: [
        if (terminalController.value != null)
          Container(
            width: double.infinity,
            height: 200,
            padding: const .all(8),
            color: getSelectedTheme().background,
            child: LayoutBuilder(
              builder: (_, constraints) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  terminalController.value!.fitResize(constraints.biggest);
                  terminalController.value!.activeBuffer.clear();
                  terminalController.value!.feed(sampleInput);
                });
                return TerminalView(
                  controller: terminalController.value!,
                  readOnly: true,
                  isMobile: PlatformUtils.isMobile,
                );
              },
            ),
          ),
        TerminalFontSizeSlider(
          selectedFontSize: selectedFontSize.value,
          onEnd: (value) => selectedFontSize.value = value,
          isDefault: true,
        ),
        TerminalFontFamilySelect(
          selectedFontFamily: selectedFontFamily.value,
          onChange: (selected) => selectedFontFamily.value = selected,
          isDefault: true,
        ),
        FLabel(
          label: Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .end,
            children: [
              Text('default_color_scheme'.tr()),
              if (breakpoint > .md)
                Row(
                  children: [
                    FButton(
                      variant: .ghost,
                      prefix: const Icon(LucideIcons.plus),
                      onPress: create,
                      child: Text('terminal_themes_theme_add'.tr()),
                    ),
                    FButton(
                      variant: .ghost,
                      prefix: const Icon(LucideIcons.swatchBook),
                      onPress: openBrowser,
                      child: Text('terminal_themes_theme_browser'.tr()),
                    ),
                    FButton(
                      variant: .ghost,
                      prefix: const Icon(LucideIcons.folderOpen),
                      onPress: importFile,
                      child: Text('terminal_themes_import'.tr()),
                    ),
                  ],
                )
              else
                FPopoverMenu.tiles(
                  control: .managed(controller: popoverController),
                  menu: [
                    .group(
                      children: [
                        .tile(
                          title: Text('terminal_themes_theme_add'.tr()),
                          prefix: const Icon(LucideIcons.plus),
                          onPress: () async {
                            await popoverController.hide();
                            await create();
                          },
                        ),
                        .tile(
                          title: Text('terminal_themes_theme_browser'.tr()),
                          prefix: const Icon(LucideIcons.swatchBook),
                          onPress: () async {
                            await popoverController.hide();
                            await openBrowser();
                          },
                        ),
                        .tile(
                          title: Text('terminal_themes_import'.tr()),
                          prefix: const Icon(LucideIcons.folderOpen),
                          onPress: () async {
                            await popoverController.hide();
                            await importFile();
                          },
                        ),
                      ],
                    ),
                  ],
                  builder: (_, controller, _) {
                    return FButton.icon(
                      variant: .ghost,
                      onPress: controller.toggle,
                      child: const Icon(LucideIcons.ellipsis),
                    );
                  },
                ),
            ],
          ),
          layout: .vertical,
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
                      selectedThemeId.value = defaultTerminalColorTheme.id;
                    }
                  },
                ),
            ],
          ),
        ),

        Builder(
          builder: (context) {
            final children = getConnectionsWithOverrides();
            if (children.isEmpty) {
              return const SizedBox.shrink();
            }

            return FTileGroup(
              label: Text('terminal_themes_overrides'.tr()),
              description: Text.rich(
                TextSpan(
                  children: TextUtils.renderText(
                    context,
                    'terminal_themes_overrides_description'.tr(),
                    style: subtitleStyle,
                  ),
                ),
              ),
              children: children,
            );
          },
        ),
      ],
    );
  }
}
