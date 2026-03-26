import 'package:cliq/modules/keys/view/create_or_edit_key_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class KeyCard extends HookConsumerWidget {
  final Key keyEntity;

  const KeyCard({super.key, required this.keyEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popoverController = useFPopoverController();

    edit() async {
      await popoverController.hide();
      return Commons.showResponsiveDialog(
        (_) => CreateOrEditKeyView.edit(keyEntity),
      );
    }

    delete() async {
      await popoverController.hide();
      return Commons.showDeleteDialog(
        entity: keyEntity.label,
        onDelete: () => CliqDatabase.keysService.deleteById(keyEntity.id),
      );
    }

    return FCard(
      title: Row(
        spacing: 8,
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
                  child: Icon(LucideIcons.keyRound, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        keyEntity.label,
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
            menu: [
              FItemGroup(
                children: [
                  FItem(
                    prefix: Icon(LucideIcons.pencil),
                    title: Text('Edit'),
                    onPress: edit,
                  ),
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
