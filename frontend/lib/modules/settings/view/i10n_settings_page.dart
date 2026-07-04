import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';

class I10nSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'i10n',
  );

  const I10nSettingsPage({super.key});

  @override
  String get title => 'language'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Column(
                  mainAxisAlignment: .center,
                  spacing: 16,
                  children: [
                    FSelectTileGroup(
                      control: .lifted(
                        value: {context.locale},
                        onChange: (value) {
                          if (value.isNotEmpty) {
                            context.setLocale(value.last);
                          }
                        },
                      ),
                      children: [
                        for (final locale in Constants.supportedLocales)
                          .tile(
                            value: locale,
                            title: Text(locale.languageCode),
                            subtitle: Text(locale.toLanguageTag()),
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
