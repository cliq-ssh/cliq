import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_card.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show
        CliqGridColumn,
        CliqGridContainer,
        CliqGridRow,
        useBreakpoint,
        Breakpoint;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';
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
    final connections = ref.watch(connectionProvider);
    final groupedConnections = useState<Map<String, List<ConnectionFull>>>({});
    final breakpoint = useBreakpoint();

    useEffect(() {
      final Map<String, List<ConnectionFull>> grouped = {};
      for (final connection in connections.entities) {
        final group = connection.groupName ?? 'Ungrouped';
        grouped.putIfAbsent(group, () => []);
        grouped[group]!.add(connection);
      }
      groupedConnections.value = grouped;

      return null;
    }, [connections]);

    openAddHostsView() {
      if (breakpoint.index >= Breakpoint.md.index) {
        showFSheet(
          context: context,
          side: FLayout.rtl,
          builder: (_) => AddConnectionView(),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddConnectionView(),
          fullscreenDialog: true,
        ),
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
                sizes: {.sm: 12, .md: 8},
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
      child: connections.entities.isEmpty
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
                        child: Column(
                          spacing: 16,
                          children: [
                            for (final group in groupedConnections.value.entries)
                              Column(
                                spacing: 8,
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    group.key,
                                    style: typography.lg.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  for (final cf in group.value)
                                    ConnectionCard(connection: cf),
                                ],
                              ),
                          ],
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
