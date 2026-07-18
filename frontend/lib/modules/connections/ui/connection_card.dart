import 'dart:io';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/shared/ui/context_menu.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/navigation/navigation_shell.dart';
import '../../session/provider/session.provider.dart';
import '../provider/connection_service.provider.dart';
import '../view/create_or_edit_connection_view.dart';
import 'connection_icon.dart';

class ConnectionCard extends HookConsumerWidget {
  final ConnectionFull connection;

  const ConnectionCard({super.key, required this.connection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryPopoverController = useFPopoverController();
    final secondaryPopoverController = useFPopoverController();

    connect({bool isSftp = false}) async {
      await primaryPopoverController.hide();
      await secondaryPopoverController.hide();
      if (!context.mounted) return;

      if (connection.effectiveUsername == null) {
        // TODO: https://github.com/cliq-ssh/cliq/issues/446
        Commons.showToast(
          'hosts_cannot_connect_username_missing'.tr(),
          prefix: Icon(
            LucideIcons.triangleAlert,
            size: 20,
            color: context.theme.colors.destructive,
          ),
          variant: .destructive,
        );
        return;
      }

      return ref
          .read(sessionProvider.notifier)
          .createAndGo(
            NavigationShell.of(context),
            connection,
            isSftp ? .sftp : .ssh,
          );
    }

    edit() async {
      await primaryPopoverController.hide();
      await secondaryPopoverController.hide();
      return Commons.showResponsiveDialog(
        (_) => CreateOrEditConnectionView.edit(connection),
      );
    }

    delete() async {
      await primaryPopoverController.hide();
      await secondaryPopoverController.hide();
      return Commons.showDeleteDialog(
        entity: connection.label,
        onDelete: () {
          ref
              .read(connectionServiceProvider)
              .deleteById(connection.id, connection.credentialIds);
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
                prefix: Icon(LucideIcons.unplug),
                title: Text('hosts_connect_ssh'.tr()),
                onPress: connect,
              ),
              FItem(
                prefix: Icon(LucideIcons.folderOpen),
                title: Text('hosts_connect_sftp'.tr()),
                onPress: () => connect(isSftp: true),
              ),
              FItem(
                prefix: Icon(LucideIcons.pencil),
                title: Text('edit'.tr()),
                onPress: edit,
              ),
              FItem(
                variant: .destructive,
                prefix: Icon(LucideIcons.trash),
                title: Text('delete'.tr()),
                onPress: delete,
              ),
            ],
          ),
        ],
        child: child,
      );
    }

    return CustomContextMenu(
      actions: [
        .new(
          label: 'hosts_connect_ssh'.tr(),
          icon: LucideIcons.unplug,
          onPress: connect,
          shortcut: KeyboardShortcut(.enter),
        ),
        .new(
          label: 'hosts_connect_sftp'.tr(),
          icon: LucideIcons.folderOpen,
          onPress: () => connect(isSftp: true),
          shortcut: KeyboardShortcut(.enter, modifiers: {.shift}),
        ),
        .new(
          label: 'edit'.tr(),
          icon: LucideIcons.pencil,
          onPress: edit,
          shortcut: KeyboardShortcut(.keyE),
        ),
        .new(
          label: 'delete'.tr(),
          icon: LucideIcons.trash,
          variant: .destructive,
          onPress: delete,
          shortcut: Platform.isMacOS
              ? KeyboardShortcut(.backspace, modifiers: {.meta})
              : KeyboardShortcut(.delete),
        ),
      ],
      popoverController: primaryPopoverController,
      builder: (context) {
        return FCard(
          title: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: PlatformUtils.isMobile ? connect : null,
                  onDoubleTap: PlatformUtils.isDesktop ? connect : null,
                  child: Row(
                    spacing: 16,
                    children: [
                      ConnectionIcon.fromConnection(
                        connection,
                        borderRadius: 16,
                        size: 28,
                        padding: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connection.label,
                              overflow: .fade,
                              softWrap: false,
                              style: context.theme.typography.body.lg,
                            ),
                            if (connection.effectiveUsername != null)
                              Text(
                                connection.effectiveUsername!,
                                style: context.theme.typography.body.xs
                                    .copyWith(
                                      color:
                                          context.theme.colors.mutedForeground,
                                      fontWeight: .normal,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        );
      },
    );
  }
}
