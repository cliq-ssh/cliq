import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_card.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';
import '../../../shared/utils/commons.dart';
import 'create_or_edit_connection_view.dart';

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
    final connections = ref.watch(connectionProvider);
    final groupedConnections = useState<Map<String, List<ConnectionFull>>>({});

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

    return Padding(
      padding: const .only(top: 16),
      child: EntityCardView<ConnectionFull>.grouped(
        groupedEntities: groupedConnections.value,
        viewTypeKey: .connectionsCardViewType,
        entityCardBuilder: (connection) =>
            ConnectionCard(connection: connection),
        noEntitiesTitle: 'No Hosts',
        noEntitiesSubtitle: 'Add your first host by clicking the button below.',
        addEntityTitle: 'Add Host',
        filterableFields: (c) => [
          c.label,
          c.effectiveUsername,
          c.port.toString(),
        ],
        onAddEntity: () => Commons.showResponsiveDialog(
          (_) => CreateOrEditConnectionView.create(),
        ),
      ),
    );
  }
}
