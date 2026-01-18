import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/modules/identities/view/create_or_edit_identity_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_ui/cliq_ui.dart' show useBreakpoint;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class IdentityCard extends HookConsumerWidget {
  final IdentityFull identity;

  const IdentityCard({super.key, required this.identity});

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
                  child: Icon(LucideIcons.users, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(identity.label),
                    Text(
                      identity.username,
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    if (identity.credentialIds.isNotEmpty)
                      Text(
                        '${identity.credentialIds.length} credential(s)',
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
                    prefix: Icon(LucideIcons.pencil),
                    title: Text('Edit'),
                    onPress: () => Commons.showResponsiveDialog(
                      context,
                      breakpoint,
                      (_) => CreateOrEditIdentityView.edit(identity),
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
                          'Are you sure you want to delete ${identity.label}? This action cannot be undone.',
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
                              CliqDatabase.identityService.deleteById(
                                identity.id,
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
