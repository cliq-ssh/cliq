import 'package:cliq/shared/data/database.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/utils/commons.dart';

class KnownHostCard extends HookConsumerWidget {
  final KnownHost knownHost;

  const KnownHostCard({super.key, required this.knownHost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popoverController = useFPopoverController();

    delete() async {
      await popoverController.hide();
      return Commons.showDeleteDialog(
        entity: knownHost.host,
        onDelete: () => CliqDatabase.knownHostService.deleteById(knownHost.id),
      );
    }

    return FCard(
      title: Row(
        spacing: 8,
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
                    color: context.theme.colors.border,
                    borderRadius: .circular(16),
                  ),
                  child: Icon(LucideIcons.fingerprintPattern, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        knownHost.host,
                        overflow: .fade,
                        softWrap: false,
                        style: context.theme.typography.lg,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FPopoverMenu(
            control: .managed(controller: popoverController),
            menu: [
              FItemGroup(
                children: [
                  FItem(
                    prefix: Icon(LucideIcons.trash),
                    title: Text('Delete'),
                    onPress: delete,
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
