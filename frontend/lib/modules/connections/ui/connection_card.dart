import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../data/database.dart';
import '../../../routing/view/navigation_shell.dart';
import '../../../shared/extensions/color.extension.dart';
import '../../session/provider/session.provider.dart';

class ConnectionCard extends HookConsumerWidget {
  final Connection connection;
  final Identity? identity;

  const ConnectionCard({
    super.key,
    required this.connection,
    required this.identity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = connection.username ?? identity?.username;

    return FCard(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              spacing: 16,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: connection.color == null
                        ? Colors.transparent
                        : ColorExtension.fromHex(connection.color!),
                    borderRadius: .circular(16),
                  ),
                  child: Icon(connection.icon.iconData, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(connection.label ?? connection.address),
                    if (username != null)
                      Text(
                        username,
                        style: context.theme.typography.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                          fontWeight: .normal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          FPopoverMenu(
            menu: [
              FItemGroup(
                children: [
                  FItem(
                    prefix: Icon(LucideIcons.unplug),
                    title: Text('Connect'),
                    onPress: () => ref
                        .read(sessionProvider.notifier)
                        .createAndGo(NavigationShell.of(context), connection),
                  ),
                  FItem(
                    prefix: Icon(LucideIcons.pencil),
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
            builder: (_, controller, _) => FButton.icon(
              onPress: controller.toggle,
              child: Icon(LucideIcons.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
