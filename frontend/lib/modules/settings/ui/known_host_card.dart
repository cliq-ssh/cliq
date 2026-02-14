import 'package:cliq/shared/data/database.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class KnownHostCard extends HookConsumerWidget {
  final KnownHost knownHost;

  const KnownHostCard({super.key, required this.knownHost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    children: [Text(knownHost.host, overflow: .fade, softWrap: false, style: context.theme.typography.lg)],
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
                          'Are you sure you want to delete the fingerprint of ${knownHost.host}? This action cannot be undone.',
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
                              CliqDatabase.knownHostService.deleteById(
                                knownHost.id,
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
