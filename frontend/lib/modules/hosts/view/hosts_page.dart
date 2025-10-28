import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/routing/router.extension.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../routing/page_path.dart';
import '../../add_host/view/add_host_page.dart';

class HostsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  const HostsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HostsPageState();
}

class _HostsPageState extends ConsumerState<HostsPage> {
  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final connections = useState<List<(Connection, Identity?)>>([]);

    // Fetch connections from database
    useEffect(() {
      Future.microtask(() async {
        connections.value = await CliqDatabase.connectionService
            .findAllWithIdentities();
      });
      return null;
    }, []);

    buildNoHosts() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: {Breakpoint.sm: 8},
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CliqTypography(
                      'No Hosts',
                      textAlign: TextAlign.center,
                      size: typography.h3,
                    ),
                    CliqTypography(
                      'Add your first host by clicking the button below.',
                      textAlign: TextAlign.center,
                      size: typography.copyM,
                    ),
                    const SizedBox(height: 8),
                    CliqButton(
                      icon: Icon(LucideIcons.plus),
                      label: Text('Add Host'),
                      onPressed: () =>
                          context.pushPath(AddHostsPage.pagePath.build()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return CliqScaffold(
      header: CliqHeader(
        right: [CliqIconButton(icon: Icon(LucideIcons.search))],
      ),
      body: connections.value.isEmpty
          ? buildNoHosts()
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 80),
              itemCount: connections.value.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 16),
              itemBuilder: (ctx, index) {
                final connection = connections.value[index];
                return CliqGridContainer(
                  children: [
                    CliqGridRow(
                      children: [
                        CliqGridColumn(
                          child: GestureDetector(
                            onTap: () {
                              // TODO:
                            },
                            child: CliqCard(
                              title: Text(
                                connection.$1.label ?? connection.$1.address,
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(LucideIcons.user),
                                  CliqTypography(
                                    connection.$2?.username ?? '<no user>',
                                    size: typography.copyXS,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
