import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/modules/keys/ui/create_or_edit_key_sheet.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/ui/title_card.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const KeyCard({super.key, required final Key keyEntity})
    extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popoverController = useFPopoverController();

    edit() async {
      await popoverController.hide();
      if (!context.mounted) return;

      return Commons.showResponsiveSheet(
        (_) => CreateOrEditKeySheet.edit(keyEntity),
        context: context,
      );
    }

    delete() async {
      await popoverController.hide();
      return Commons.showDeleteDialog(
        entity: keyEntity.label,
        onDelete: () async {
          await ref.read(keyServiceProvider).deleteById(keyEntity.id);
          await ref.read(syncProvider.notifier).pullAndPushVault();
        },
      );
    }

    return TitleCard(
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
                  child: const Icon(LucideIcons.keyRound, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        keyEntity.label,
                        overflow: .fade,
                        softWrap: false,
                        style: context.theme.typography.body.lg,
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
                    prefix: const Icon(LucideIcons.pencil),
                    title: Text('edit'.tr()),
                    onPress: edit,
                  ),
                  FItem(
                    variant: .destructive,
                    prefix: const Icon(LucideIcons.trash),
                    title: Text('delete'.tr()),
                    onPress: delete,
                  ),
                ],
              ),
            ],
            builder: (_, controller, _) => FButton.icon(
              onPress: controller.toggle,
              child: const Icon(LucideIcons.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
