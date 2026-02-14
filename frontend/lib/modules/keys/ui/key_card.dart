import 'package:cliq/modules/keys/view/create_or_edit_key_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class KeyCard extends HookConsumerWidget {
  final Key keyEntity;

  const KeyCard({super.key, required this.keyEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      Text(keyEntity.label, overflow: .fade, softWrap: false, style: context.theme.typography.lg),
                    ],
                  ),
                )
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
                    onPress: () => Commons.showResponsiveDialog(
                      context,
                      (_) => CreateOrEditKeyView.edit(keyEntity),
                    ),
                  ),
                  FItem(
                    prefix: Icon(LucideIcons.trash),
                    title: Text('Delete'),
                    onPress: () => showFDialog(
                      context: context,
                      builder: (context, style, animation) => FDialog(
                        style: style,
                        animation: animation,
                        direction: Axis.horizontal,
                        title: const Text('Are you sure?'),
                        body: Text(
                          'Are you sure you want to delete ${keyEntity.label}? This action cannot be undone.',
                        ),
                        actions: [
                          FButton(
                            variant: .outline,
                            child: const Text('Cancel'),
                            onPress: () => Navigator.of(context).pop(),
                          ),
                          FButton(
                            variant: .destructive,
                            child: const Text('Delete'),
                            onPress: () {
                              CliqDatabase.keysService.deleteById(keyEntity.id);
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
