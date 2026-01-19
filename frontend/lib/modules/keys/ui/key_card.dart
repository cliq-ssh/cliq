import 'package:cliq/modules/keys/view/create_or_edit_key_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_ui/cliq_ui.dart' show useBreakpoint;
import 'package:flutter/material.dart' hide Key;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class KeyCard extends HookConsumerWidget {
  final Key keyEntity;

  const KeyCard({super.key, required this.keyEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = useBreakpoint();

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
                    color: context.theme.colors.border,
                    borderRadius: .circular(16),
                  ),
                  child: Icon(LucideIcons.keyRound, size: 28),
                ),
                Text(keyEntity.label),
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
                      breakpoint,
                      (_) => CreateOrEditKeyView.edit(keyEntity),
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
                          'Are you sure you want to delete ${keyEntity.label}? This action cannot be undone.',
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
