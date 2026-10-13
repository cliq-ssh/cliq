import 'package:cliq/modules/settings/provider/log_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extension/logging.extension.dart';
import 'package:cliq/shared/ui/title_card.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
import 'package:easy_localization/easy_localization.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:material_ui/material_ui.dart';

class const LogCard({super.key, required final Log log})
    extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popoverController = useFPopoverController();
    final level = LevelExtension.fromValue(log.logLevel);

    delete() async {
      await popoverController.hide();
      return Commons.showDeleteDialog(
        entity: 'Log #${log.id}',
        onDelete: () async {
          await ref.read(logServiceProvider).deleteById(log.id);
        },
      );
    }

    copy() async {
      await Commons.copyToClipboard(
        context,
        '[${log.createdAt.toIso8601String()}] [${level.name}] [${log.loggerName}] ${log.message}',
      );
      await popoverController.hide();
    }

    return TitleCard(
      tintColor: level.toColor(),
      title: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              log.message.trim(),
              style: context.theme.typography.body.xs.copyWith(
                fontFamily: CliqFontFamily.secondary.fontFamily,
                color: context.theme.colors.foreground,
              ),
            ),
          ),
          FPopoverMenu(
            control: .managed(controller: popoverController),
            menu: [
              .group(
                children: [
                  .item(
                    prefix: const Icon(LucideIcons.copy),
                    title: Text('copy'.tr()),
                    onPress: copy,
                  ),
                  .item(
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
      subtitle: Text(
        'log_title'.tr(
          namedArgs: {
            'level': level.name,
            'loggerName': log.loggerName,
            'timestamp': log.createdAt.toIso8601String(),
          },
        ),
        style: context.theme.typography.body.xs.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}
