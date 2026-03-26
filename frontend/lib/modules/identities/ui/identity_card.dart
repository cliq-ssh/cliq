import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/modules/identities/view/create_or_edit_identity_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class IdentityCard extends HookConsumerWidget {
  final IdentityFull identity;

  const IdentityCard({super.key, required this.identity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popoverController = useFPopoverController();

    edit() async {
      await popoverController.hide();
      return Commons.showResponsiveDialog(
        (_) => CreateOrEditIdentityView.edit(identity),
      );
    }

    delete() async {
      await popoverController.hide();
      return Commons.showDeleteDialog(
        entity: identity.label,
        onDelete: () {
          CliqDatabase.identityService.deleteById(
            identity.id,
            identity.credentialIds,
          );
        },
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
                  child: Icon(LucideIcons.users, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        identity.label,
                        overflow: .fade,
                        softWrap: false,
                        style: context.theme.typography.lg,
                      ),
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
