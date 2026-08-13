import 'dart:io';

import 'package:cliq/modules/settings/view/create_or_edit_terminal_theme_view.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/ui/context_menu.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/title_card.dart';
import '../../../shared/utils/commons.dart';
import '../provider/terminal_theme_service.provider.dart';

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

    final isBuiltIn = theme.id == "-1";

    buildColor(Color color) {
      return Container(width: 8, height: 16, color: color);
    }

    duplicate() async {
      await primaryPopoverController.hide();
      await secondaryPopoverController.hide();

      final copyInsert = CustomTerminalThemesCompanion.insert(
        name: '${theme.name} - Copy',
        black: theme.black,
        red: theme.red,
        green: theme.green,
        yellow: theme.yellow,
        blue: theme.blue,
        purple: theme.purple,
        cyan: theme.cyan,
        white: theme.white,
        brightBlack: theme.brightBlack,
        brightRed: theme.brightRed,
        brightGreen: theme.brightGreen,
        brightYellow: theme.brightYellow,
        brightBlue: theme.brightBlue,
        brightPurple: theme.brightPurple,
        brightCyan: theme.brightCyan,
        brightWhite: theme.brightWhite,
        background: theme.background,
        foreground: theme.foreground,
        cursor: theme.cursor,
        cursorText: theme.cursorText,
        selectionBackground: theme.selectionBackground,
        selectionForeground: theme.selectionForeground,
      );

      await ref
          .read(terminalThemeServiceProvider)
          .createCustomTerminalTheme(copyInsert);
    }

    edit() async {
      await primaryPopoverController.hide();
      await secondaryPopoverController.hide();
      if (!context.mounted) return;

      return Commons.showResponsiveDialog(
        (_) => CreateOrEditTerminalThemeView.edit(theme),
        context: context,
      ).then((_) => onEdit?.call());
    }

    delete() async {
      await primaryPopoverController.hide();
      await secondaryPopoverController.hide();

      return Commons.showDeleteDialog(
        entity: theme.name,
        onDelete: () {
          ref.read(terminalThemeServiceProvider).deleteById(theme.id);
          onDelete?.call();
        },
      );
    }

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
                prefix: Icon(LucideIcons.copy),
                title: Text('Duplicate'),
                onPress: duplicate,
              ),
              if (!isBuiltIn) ...[
                FItem(
                  prefix: Icon(LucideIcons.pencil),
                  title: Text('Edit'),
                  onPress: edit,
                ),
                FItem(
                  prefix: Icon(LucideIcons.trash),
                  title: Text('Delete'),
                  variant: .destructive,
                  onPress: delete,
                ),
              ],
            ],
          ),
        ],
        child: child,
      );
    }

    return CustomContextMenu(
      actions: [
        .new(label: 'Duplicate', icon: LucideIcons.copy, onPress: duplicate),
        if (!isBuiltIn) ...[
          .new(
            label: 'Edit',
            icon: LucideIcons.pencil,
            onPress: edit,
            shortcut: KeyboardShortcut(.keyE),
          ),
          .new(
            label: 'Delete',
            icon: LucideIcons.trash,
            variant: .destructive,
            onPress: delete,
            shortcut: Platform.isMacOS
                ? KeyboardShortcut(.backspace, modifiers: {.meta})
                : KeyboardShortcut(.delete),
          ),
        ],
      ],
      popoverController: primaryPopoverController,
      builder: (context) {
        return GestureDetector(
          onTap: onTap,
          child: TitleCard(
            title: Row(
              spacing: 16,
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      children: [
                        theme.black,
                        theme.red,
                        theme.green,
                        theme.yellow,
                        theme.blue,
                        theme.purple,
                        theme.cyan,
                        theme.white,
                      ].map(buildColor).toList(),
                    ),
                    Row(
                      children: [
                        theme.brightBlack,
                        theme.brightRed,
                        theme.brightGreen,
                        theme.brightYellow,
                        theme.brightBlue,
                        theme.brightPurple,
                        theme.brightCyan,
                        theme.brightWhite,
                      ].map(buildColor).toList(),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(theme.name),
                      if (theme.id == '-1')
                        Text(
                          'built-in',
                          style: context.theme.typography.body.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                            fontWeight: .normal,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected) Icon(LucideIcons.check),
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
