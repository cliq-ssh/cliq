import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/modules/settings/provider/log.provider.dart';
import 'package:cliq/modules/settings/provider/log_service.provider.dart';
import 'package:cliq/modules/settings/ui/log_card.dart';
import 'package:cliq/shared/extension/logging.extension.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/cliq_tooltip.dart';
import 'package:cliq/shared/ui/list_icon.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow, useBreakpoint;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const LogsSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'logs',
  );

  static final _allLevels = Level.LEVELS
      .where((level) => level != Level.OFF && level != Level.ALL)
      .toList();

  @override
  String get title => 'logs'.tr();

  @override
  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) =>
      body;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;
    final breakpoint = useBreakpoint();

    final logs = ref.watch(logProvider);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text
        .trim()
        .toLowerCase();
    final filterLevelValues = useState<Set<int>>(
      _allLevels.map((level) => level.value).toSet(),
    );

    final filteredLogs = useMemoized(() {
      final sortedEntities = logs.entities.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return sortedEntities.where((log) {
        if (!filterLevelValues.value.contains(log.logLevel)) return false;
        if (filterText.isEmpty) return true;

        final level = LevelExtension.fromValue(log.logLevel);
        return log.message.toLowerCase().contains(filterText) ||
            log.loggerName.toLowerCase().contains(filterText) ||
            level.name.toLowerCase().contains(filterText);
      }).toList();
    }, [logs.entities, filterText, filterLevelValues.value]);

    deleteAll() async {
      await Commons.showDeleteDialog(
        entity: 'logs_all'.tr(),
        onDelete: () async {
          await ref.read(logServiceProvider).deleteAll();
        },
      );
    }

    exportLogs() async {
      final buffer = StringBuffer();
      for (final log in filteredLogs) {
        final level = LevelExtension.fromValue(log.logLevel);
        buffer.writeln(
          '[${log.createdAt.toIso8601String()}] [${level.name}] [${log.loggerName}] ${log.message}',
        );
      }

      if (PlatformUtils.isMobile) {
        await Commons.shareText(buffer.toString(), subject: 'logs.txt');
      } else {
        await Commons.saveTextToFile(
          buffer.toString(),
          'logs.txt',
          allowedExtensions: ['txt'],
        );
      }
    }

    filterLogsByLevel(int levelValue) {
      final newSet = Set<int>.from(filterLevelValues.value);
      if (newSet.contains(levelValue)) {
        newSet.remove(levelValue);
      } else {
        newSet.add(levelValue);
      }
      filterLevelValues.value = newSet;
    }

    buildNoMatch() {
      return Center(
        child: Column(
          spacing: 8,
          mainAxisSize: .min,
          children: [
            Text(
              'filters_no_match'.tr(),
              textAlign: TextAlign.center,
              style: typography.body.md.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            FButton(
              variant: .outline,
              mainAxisSize: .min,
              onPress: () {
                filterController.clear();
                filterLevelValues.value = Level.LEVELS
                    .map((level) => level.value)
                    .toSet();
              },
              child: Text('filters_reset'.tr()),
            ),
          ],
        ),
      );
    }

    buildDeleteAllButton() {
      return CliqTooltip(
        text: Text('delete_all'.tr()),
        child: FButton.icon(
          onPress: deleteAll,
          variant: .destructive,
          child: const Icon(LucideIcons.trash),
        ),
      );
    }

    buildDownloadButton() {
      return CliqTooltip(
        text: PlatformUtils.isMobile ? Text('share'.tr()) : Text('export'.tr()),
        child: FButton.icon(
          onPress: exportLogs,
          child: const Icon(LucideIcons.download),
        ),
      );
    }

    buildFilterMenuButton() {
      return CliqTooltip(
        text: Text('filter'.tr()),
        child: FPopoverMenu(
          menu: [
            .group(
              children: [
                for (final level in _allLevels)
                  .item(
                    title: Text(level.name),
                    prefix: ListIcon(
                      type: .checkbox,
                      selected: filterLevelValues.value.contains(level.value),
                      color: level.toColor(),
                    ),
                    onPress: () => filterLogsByLevel(level.value),
                  ),
              ],
            ),
          ],
          builder: (context, controller, _) {
            return FButton.icon(
              onPress: controller.toggle,
              child: const Icon(LucideIcons.listFilter),
            );
          },
        ),
      );
    }

    buildCombinedOptionsButton() {
      return FPopoverMenu(
        menu: [
          .group(
            children: [
              .submenu(
                title: Text('filter'.tr()),
                prefix: const Icon(LucideIcons.listFilter),
                submenu: [
                  .group(
                    children: [
                      for (final level in _allLevels)
                        .item(
                          title: Text(level.name),
                          prefix: Icon(
                            filterLevelValues.value.contains(level.value)
                                ? LucideIcons.circleCheck
                                : LucideIcons.circle,
                            color: level.toColor(),
                          ),
                          onPress: () => filterLogsByLevel(level.value),
                        ),
                    ],
                  ),
                ],
              ),
              .item(
                title: Text('share'.tr()),
                prefix: const Icon(LucideIcons.share),
                onPress: exportLogs,
              ),
              .item(
                title: Text('delete_all'.tr()),
                variant: .destructive,
                prefix: const Icon(LucideIcons.trash),
                onPress: deleteAll,
              ),
            ],
          ),
        ],
        builder: (context, controller, _) {
          return FButton.icon(
            onPress: controller.toggle,
            child: const Icon(LucideIcons.ellipsis),
          );
        },
      );
    }

    if (logs.entities.isEmpty) {
      return Center(child: Text('no_logs'.tr()));
    }

    return Column(
      children: [
        CliqGridContainer(
          children: [
            CliqGridRow(
              children: [
                CliqGridColumn(
                  sizes: const {.sm: 8, .md: 6, .lg: 4},
                  child: Padding(
                    padding: const .only(bottom: 16),
                    child: CliqTooltip(
                      text: TextWithShortcutInfo(
                        'filter_items'.tr(),
                        shortcut: KeyboardShortcut(
                          .keyF,
                          modifiers: {.control},
                        ),
                      ),
                      child: FTextField(
                        control: .managed(controller: filterController),
                        hint: 'filter'.tr(),
                        prefixBuilder: (_, _, _) => IconTheme(
                          data: context.theme.textFieldStyles.md.iconStyle.base,
                          child: const Padding(
                            padding: .only(left: 8, right: 4),
                            child: Icon(LucideIcons.search),
                          ),
                        ),
                        clearable: (value) => value.text.isNotEmpty,
                      ),
                    ),
                  ),
                ),
                CliqGridColumn(
                  sizes: const {.sm: 4, .md: 6, .lg: 8},
                  child: FTooltipGroup(
                    child: Row(
                      mainAxisAlignment: .end,
                      spacing: 8,
                      children: [
                        if (breakpoint < .md)
                          buildCombinedOptionsButton()
                        else ...[
                          buildFilterMenuButton(),
                          buildDownloadButton(),
                          buildDeleteAllButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: filteredLogs.isEmpty
              ? buildNoMatch()
              : ListView.separated(
                  padding: .zero,
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return CliqGridContainer(
                      children: [
                        CliqGridRow(
                          children: [
                            CliqGridColumn(
                              child: LogCard(log: filteredLogs[index]),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
