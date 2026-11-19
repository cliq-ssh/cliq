import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/shared/provider/tab.provider.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_grid/cliq_grid.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const NewTabPage({super.key, required final String tabId})
    extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionProvider);
    final filterController = useTextEditingController();

    buildNoMatch() {
      return Column(
        spacing: 8,
        children: [
          Text(
            'filters_no_match'.tr(),
            textAlign: TextAlign.center,
            style: context.theme.typography.body.md.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          Row(
            mainAxisSize: .min,
            children: [
              FButton(
                variant: .outline,
                onPress: filterController.clear,
                child: Text('filters_reset'.tr()),
              ),
            ],
          ),
        ],
      );
    }

    return CliqGridContainer(
      alignment: .topCenter,
      children: [
        CliqGridRow(
          children: [
            CliqGridColumn(
              child: Column(
                spacing: 20,
                children: [
                  Padding(
                    padding: const .only(top: 20),
                    child: FTextField(
                      control: .managed(controller: filterController),
                      hint: 'filter'.tr(),
                      autofocus: true,
                      prefixBuilder: (_, _, _) => IconTheme(
                        data: context.theme.textFieldStyles.md.iconStyle.base,
                        child: const Padding(
                          padding: .only(left: 8, right: 4),
                          child: Icon(LucideIcons.search),
                        ),
                      ),
                      clearable: (value) => value.text.isNotEmpty,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: filterController,
                    builder: (context, value, _) {
                      final filtered = connections.entities
                          .where((c) => TextUtils.matches(c, value.text))
                          .toList();

                      if (filtered.isEmpty) {
                        return value.text.isEmpty
                            ? const SizedBox.shrink()
                            : buildNoMatch();
                      }

                      return FTileGroup(
                        children: [
                          for (final connection in filtered)
                            .tile(
                              prefix: ConnectionIcon.fromConnection(
                                connection,
                                size: 20,
                                padding: 8,
                                borderRadius: 12,
                              ),
                              suffix: Row(
                                spacing: 8,
                                mainAxisSize: .min,
                                mainAxisAlignment: .end,
                                children: [
                                  FButton.icon(
                                    child: const Icon(LucideIcons.terminal),
                                    onPress: () => ref
                                        .read(tabProvider.notifier)
                                        .goSsh(
                                          tabId,
                                          ref
                                              .read(sessionProvider.notifier)
                                              .create(connection),
                                        ),
                                  ),
                                  FButton.icon(
                                    child: const Icon(LucideIcons.folder),
                                    onPress: () => ref
                                        .read(tabProvider.notifier)
                                        .goSsh(
                                          tabId,
                                          ref
                                              .read(sessionProvider.notifier)
                                              .create(connection, sftp: true),
                                        ),
                                  ),
                                ],
                              ),
                              title: Text(connection.label),
                              subtitle: Text(
                                connection.effectiveUsername ??
                                    connection.addressAndPort,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
