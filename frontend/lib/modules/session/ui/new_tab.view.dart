import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq_grid/cliq_grid.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class const NewTabView({super.key}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionProvider);

    // TODO: make functional
    final filterController = useTextEditingController();

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
                  FTileGroup(
                    children: [
                      for (final connection in connections.entities)
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
                                onPress: () {
                                  // TODO: open ssh
                                },
                              ),
                              FButton.icon(
                                child: const Icon(LucideIcons.folder),
                                onPress: () {
                                  // TODO: open sftp
                                },
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
