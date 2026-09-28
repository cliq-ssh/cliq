import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/modules/settings/provider/log.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide Router;
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

  static String _levelName(int value) => Level.LEVELS
      .firstWhere(
        (l) => l.value == value,
        orElse: () => Level('LEVEL$value', value),
      )
      .name;

  @override
  String get title => 'logs'.tr();

  @override
  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) =>
      body;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;
    final logs = ref.watch(logProvider);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text
        .trim()
        .toLowerCase();

    final filteredLogs = useMemoized(() {
      if (filterText.isEmpty) return logs.entities;

      return logs.entities.where((log) {
        return log.message.toLowerCase().contains(filterText) ||
            log.loggerName.toLowerCase().contains(filterText) ||
            _levelName(log.logLevel).toLowerCase().contains(filterText);
      }).toList();
    }, [logs.entities, filterText]);

    Widget buildLogCard(Log log) {
      final isError = log.logLevel >= Level.SEVERE.value;

      return FTile(
        variant: isError ? .destructive : .primary,
        title: Text(
          'log_title'.tr(
            namedArgs: {
              'loggerName': log.loggerName,
              'timestamp': log.createdAt.toIso8601String(),
            },
          ),
        ),
        subtitle: Text(log.message.trim()),
      );
    }

    Widget buildNoMatch() {
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
              onPress: filterController.clear,
              child: Text('filters_reset'.tr()),
            ),
          ],
        ),
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
                  child: Padding(
                    padding: const .only(bottom: 16),
                    child: Align(
                      alignment: .centerLeft,
                      child: ConstrainedBox(
                        constraints: const .new(maxWidth: 250),
                        child: FTextField(
                          control: .managed(controller: filterController),
                          hint: 'filter'.tr(),
                          prefixBuilder: (_, _, _) => IconTheme(
                            data:
                                context.theme.textFieldStyles.md.iconStyle.base,
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
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: filteredLogs.isEmpty
              ? buildNoMatch()
              : ListView.separated(
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return CliqGridContainer(
                      children: [
                        CliqGridRow(
                          children: [
                            CliqGridColumn(
                              child: buildLogCard(filteredLogs[index]),
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
