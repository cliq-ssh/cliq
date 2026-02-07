import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/navigation_shell.dart';
import '../../session/provider/session.provider.dart';
import '../view/create_or_edit_connection_view.dart';

class ConnectionCard extends HookConsumerWidget {
  final ConnectionFull connection;

  const ConnectionCard({super.key, required this.connection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryPopoverController = useFPopoverController();
    final secondaryPopoverController = useFPopoverController();

    connect() {
      ref
          .read(sessionProvider.notifier)
          .createAndGo(NavigationShell.of(context), connection);
    }

    buildPopoverMenu({required FPopoverController controller, required Widget child}) {
      return FPopoverMenu(
        control: .managed(controller: controller),
        menu: [
          FItemGroup(
            children: [
              FItem(
                prefix: Icon(LucideIcons.unplug),
                title: Text('Connect'),
                onPress: connect,
              ),
              FItem(
                prefix: Icon(LucideIcons.pencil),
                title: Text('Edit'),
                onPress: () => Commons.showResponsiveDialog(
                  context,
                  (_) => CreateOrEditConnectionView.edit(connection),
                ),
              ),
              FItem(
                prefix: Icon(LucideIcons.trash),
                title: Text('Delete'),
                onPress: () => showFDialog(
                  context: context,
                  builder: (context, style, animation) => FDialog(
                    style: style.call,
                    animation: animation,
                    direction: Axis.horizontal,
                    title: const Text('Are you sure?'),
                    body: Text(
                      'Are you sure you want to delete ${connection.label}? This action cannot be undone.',
                    ),
                    actions: [
                      FButton(
                        style: FButtonStyle.outline(),
                        child: const Text('Cancel'),
                        onPress: () => Navigator.of(context).pop(),
                      ),
                      FButton(
                        style: FButtonStyle.destructive(),
                        child: const Text('Delete'),
                        onPress: () {
                          CliqDatabase.connectionService.deleteById(
                            connection.id,
                            connection.credentialIds,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        child: child,
      );
    }

    return buildPopoverMenu(controller: primaryPopoverController, child: GestureDetector(
      onDoubleTap: connect,
      onSecondaryTap: () {
        secondaryPopoverController.hide();
        primaryPopoverController.toggle();
      },
      child: FCard(
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
                      color: connection.iconBackgroundColor,
                      borderRadius: .circular(16),
                    ),
                    child: Icon(
                      connection.icon.iconData,
                      color: connection.iconColor,
                      size: 28,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(connection.label),
                      Text(
                        connection.effectiveUsername,
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
            buildPopoverMenu(
              controller: secondaryPopoverController,
              child: FButton.icon(
                onPress: () {
                  primaryPopoverController.hide();
                  secondaryPopoverController.toggle();
                },
                child: Icon(LucideIcons.ellipsis),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
