import 'package:cliq/modules/settings/provider/known_host_service.provider.dart';
import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/ui/title_card.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const KnownHostCard({super.key, required final KnownHost knownHost})
    extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popoverController = useFPopoverController();

    delete() async {
      await popoverController.hide();
      return Commons.showDeleteDialog(
        entity: knownHost.host,
        onDelete: () async {
          await ref.read(knownHostServiceProvider).deleteById(knownHost.id);
          await ref.read(syncProvider.notifier).pullAndPushVault();
        },
      );
    }

    return TitleCard(
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
                  child: const Icon(LucideIcons.fingerprintPattern, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        knownHost.host,
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
            control: .managed(controller: popoverController),
            menu: [
              FItemGroup(
                children: [
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
