import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/routing/router.extension.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow, Breakpoint;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
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
                    Text(
                      'No Hosts',
                      textAlign: TextAlign.center,
                      style: typography.xl2,
                    ),
                    Text(
                      'Add your first host by clicking the button below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    FButton(
                      prefix: Icon(LucideIcons.plus),
                      child: Text('Add Host'),
                      onPress: () =>
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

    return FScaffold(
      child: connections.value.isEmpty
          ? buildNoHosts()
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 80),
              child: CliqGridContainer(
                children: [
                  CliqGridRow(
                    children: [
                      CliqGridColumn(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FButton(
                                style: FButtonStyle.ghost(),
                                prefix: Icon(LucideIcons.plus),
                                onPress: () {
                                  context.pushPath(
                                    AddHostsPage.pagePath.build(),
                                  );
                                },
                                child: Text('Add Host'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CliqGridColumn(
                        child: GestureDetector(
                          onTap: () {
                            // TODO:
                          },
                          child: Column(
                            spacing: 16,
                            children: [
                              for (final connection in connections.value)
                                FCard(
                                  title: Text(
                                    connection.$1.label ??
                                        connection.$1.address,
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        connection.$1.username ??
                                            connection.$2?.username ??
                                            '<no user>',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
