import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../routing/page_path.dart';
import '../../../shared/ui/future_wrapper.dart';

class LicenseSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'licenses',
  );

  const LicenseSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return FutureWrapper(
      future: LicenseRegistry.licenses.toList(),
      onSuccess: (ctx, snap) {
        final List<LicenseEntry> licenses = snap.data ?? [];
        final Map<String, List<LicenseEntry>> licensesMap = {};

        for (final license in licenses) {
          for (final package in license.packages) {
            final identifier = package.toString();
            if (licensesMap.containsKey(identifier)) {
              licensesMap[identifier]!.add(license);
            } else {
              licensesMap[identifier] = [license];
            }
          }
        }

        LucideIcons.aArrowDown;
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 80),
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
                            child: CliqCard(
                              title: Text(license.key),
                              subtitle: Text(
                                '${license.value.length} license(s)',
                              ),
                              trailing: isExpanded
                                  ? null
                                  : CliqIconButton(
                                      onPressed: toggle,
                                      icon: Icon(LucideIcons.chevronDown),
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
