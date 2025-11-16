import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/routing/view/navigation_shell.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../data/database.dart';
import '../../../routing/model/page_path.model.dart';
import 'add_connection_view.dart';

class ConnectionsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  const ConnectionsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConnectionsPageState();
}

class _ConnectionsPageState extends ConsumerState<ConnectionsPage> {
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

    openAddHostsView() {
      // TODO: implement mobile

      showFSheet(
        context: context,
        side: FLayout.rtl,
        builder: (_) => AddConnectionView(),
      );
    }

    buildNoHosts() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: {.sm: 8},
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
                      onPress: openAddHostsView,
                      child: Text('Add Host'),
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
                                onPress: openAddHostsView,
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
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        connection.$1.label ??
                                            connection.$1.address,
                                      ),
                                      FPopoverMenu(
                                        menu: [
                                          FItemGroup(
                                            children: [
                                              FItem(
                                                prefix: Icon(
                                                  LucideIcons.unplug,
                                                ),
                                                title: Text('Connect'),
                                                onPress: () => ref
                                                    .read(
                                                      sessionProvider.notifier,
                                                    )
                                                    .createAndGo(
                                                      NavigationShell.of(
                                                        context,
                                                      ),
                                                      connection.$1,
                                                    ),
                                              ),
                                              FItem(
                                                prefix: Icon(
                                                  LucideIcons.pencil,
                                                ),
                                                title: Text('Edit'),
                                                onPress: () {},
                                              ),
                                              FItem(
                                                prefix: Icon(LucideIcons.trash),
                                                title: Text('Delete'),
                                                onPress: () {},
                                              ),
                                            ],
                                          ),
                                        ],
                                        builder: (_, controller, _) =>
                                            FButton.icon(
                                              onPress: controller.toggle,
                                              child: Icon(LucideIcons.ellipsis),
                                            ),
                                      ),
                                    ],
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
