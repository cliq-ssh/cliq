import 'package:cliq/modules/settings/provider/known_host.provider.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';
import '../ui/known_host_card.dart';

class KnownHostsSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'known-hosts',
  );

  const KnownHostsSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final knownHosts = ref.watch(knownHostProvider);

    buildNoKnownHosts() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: {.sm: 12, .md: 8},
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No Known Hosts',
                      textAlign: TextAlign.center,
                      style: context.theme.typography.xl2,
                    ),
                    Text(
                      'No known hosts have been added yet. Connect to a host to add it to your known hosts list.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return knownHosts.entities.isEmpty
        ? buildNoKnownHosts()
        : SingleChildScrollView(
            child: CliqGridContainer(
              children: [
                CliqGridRow(
                  children: [
                    CliqGridColumn(
                      sizes: {.sm: 12, .md: 8},
                      child: Column(
                        spacing: 16,
                        children: [
                          for (final knownHost in knownHosts.entities)
                            KnownHostCard(knownHost: knownHost),
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
