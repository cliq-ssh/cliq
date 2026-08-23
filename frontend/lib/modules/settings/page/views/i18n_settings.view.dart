import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const I18nSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'i18n',
  );

  @override
  String get title => 'language'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 16,
      children: [
        FSelectTileGroup(
          control: .lifted(
            value: {context.locale},
            onChange: (value) async {
              if (value.isNotEmpty) {
                await context.setLocale(value.last);
              }
            },
          ),
          children: [
            for (final localeEntry in Constants.supportedLocales.entries)
              .tile(
                value: localeEntry.value,
                title: Text(localeEntry.key),
                subtitle: Text(localeEntry.value.toLanguageTag()),
              ),
          ],
        ),
        FTileGroup(
          children: [
            .tile(
              title: Text('language_help_translate'.tr()),
              subtitle: Text(
                'language_help_translate_subtitle'.tr(),
                overflow: .visible,
              ),
              prefix: const Icon(LucideIcons.languages),
              suffix: const Icon(LucideIcons.externalLink),
              onPress: () => Commons.launchWeblateUrl(),
            ),
          ],
        ),
      ],
    );
  }
}
