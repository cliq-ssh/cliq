import 'dart:io';

import 'package:cliq/modules/settings/view/create_or_edit_terminal_theme_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/ui/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/shortcut_info.dart';
import '../../../shared/utils/commons.dart';

class TerminalThemeCard extends HookConsumerWidget {
  final CustomTerminalTheme theme;
  final void Function() onTap;
  final bool isSelected;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TerminalThemeCard({
    super.key,
    required this.theme,
    required this.onTap,
    this.isSelected = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryPopoverController = useFPopoverController();
    final secondaryPopoverController = useFPopoverController();

    final isBuiltIn = theme.id == -1;

    buildColor(Color color) {
      return Container(width: 8, height: 16, color: color);
    }

    edit() => Commons.showResponsiveDialog(
      (_) => CreateOrEditTerminalThemeView.edit(theme),
    ).then((_) => onEdit?.call());

    delete() => Commons.showDeleteDialog(
      entity: theme.name,
      onDelete: () {
        CliqDatabase.customTerminalThemeService.deleteById(theme.id);
        onDelete?.call();
      },
    );

    buildPopoverMenu({
      required FPopoverController controller,
      required Widget child,
    }) {
      return FPopoverMenu(
        control: .managed(controller: controller),
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
        child: child,
      );
    }

    return CustomContextMenu(
      actions: isBuiltIn
          ? []
          : [
              .new(
                label: 'Edit',
                icon: LucideIcons.pencil,
                onPress: edit,
                shortcut: ShortcutActionInfo(.keyE),
              ),
              .new(
                label: 'Delete',
                icon: LucideIcons.trash,
                onPress: delete,
                shortcut: Platform.isMacOS
                    ? ShortcutActionInfo(.backspace, modifiers: {.meta})
                    : ShortcutActionInfo(.delete),
              ),
            ],
      popoverController: primaryPopoverController,
      builder: (context) {
        return GestureDetector(
          onTap: onTap,
          child: FCard(
            title: Row(
              spacing: 16,
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      children: [
                        theme.redColor,
                        theme.greenColor,
                        theme.yellowColor,
                        theme.blueColor,
                        theme.purpleColor,
                        theme.cyanColor,
                        theme.whiteColor,
                      ].map(buildColor).toList(),
                    ),
                    Row(
                      children: [
                        theme.brightRedColor,
                        theme.brightGreenColor,
                        theme.brightYellowColor,
                        theme.brightBlueColor,
                        theme.brightPurpleColor,
                        theme.brightCyanColor,
                        theme.brightWhiteColor,
                      ].map(buildColor).toList(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(theme.name),
                    if (theme.id == -1 || theme.author != null)
                      Text(
                        theme.id == -1 ? 'built-in' : theme.author!,
                        style: context.theme.typography.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                          fontWeight: .normal,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (isSelected) Icon(LucideIcons.check),
                if (!isBuiltIn)
                  buildPopoverMenu(
                    controller: secondaryPopoverController,
                    child: FButton.icon(
                      onPress: () {
                        secondaryPopoverController.toggle();
                        primaryPopoverController.hide();
                      },
                      child: Icon(LucideIcons.ellipsis),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
