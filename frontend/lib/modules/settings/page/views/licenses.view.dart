import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/future_wrapper.dart';
import 'package:cliq/shared/ui/title_card.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const LicenseSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'licenses',
  );

  @override
  String get title => 'licenses'.tr();

  @override
  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) =>
      body;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return FutureWrapper(
      future: LicenseRegistry.licenses.toList(),
      onSuccess: (ctx, snap) {
        final List<LicenseEntry> licenses = snap.data ?? [];
        final Map<String, List<LicenseEntry>> licensesMap = {};

        for (final license in licenses) {
          for (final package in license.packages) {
            final identifier = package;
            if (licensesMap.containsKey(identifier)) {
              licensesMap[identifier]!.add(license);
            } else {
              licensesMap[identifier] = [license];
            }
          }
        }

        return ListView.separated(
          itemCount: licensesMap.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
          itemBuilder: (ctx, index) {
            final MapEntry<String, List<LicenseEntry>> license = licensesMap
                .entries
                .elementAt(index);

            bool isExpanded = false;
            return CliqGridContainer(
              children: [
                CliqGridRow(
                  children: [
                    CliqGridColumn(
                      child: StatefulBuilder(
                        builder: (ctx, setState) {
                          toggle() => setState(() {
                            isExpanded = !isExpanded;
                          });
                          return GestureDetector(
                            onTap: toggle,
                            child: TitleCard(
                              title: Text(license.key),
                              subtitle: Text(
                                'licenses_subtitle'.plural(
                                  license.value.length,
                                ),
                              ),
                              child: isExpanded
                                  ? Column(
                                      children: [
                                        for (final entry in license.value) ...[
                                          for (final paragraph
                                              in entry.paragraphs) ...[
                                            Text(paragraph.text),
                                            const SizedBox(height: 10),
                                          ],
                                          const Divider(),
                                        ],
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
