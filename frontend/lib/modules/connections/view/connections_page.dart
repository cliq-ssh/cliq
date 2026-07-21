import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_card.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:easy_localization/easy_localization.dart';
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
        final group = connection.groupName ?? 'hosts_ungrouped'.tr();
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
        noEntitiesTitle: 'hosts_empty'.tr(),
        noEntitiesSubtitle: 'hosts_empty_subtitle'.tr(),
        addEntityTitle: 'hosts_add'.tr(),
        filterableFields: (c) => [
          c.vault.label,
          c.label,
          ?c.effectiveUsername,
          c.port.toString(),
        ],
        filterableVaultId: (c) => c.vaultId,
        onAddEntity: () => Commons.showResponsiveDialog(
          (_) => CreateOrEditConnectionView.create(),
          context: context,
        ),
      ),
    );
  }
}
