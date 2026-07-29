import 'package:cliq/shared/utils/commons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'create_or_edit_key_view.dart';
import 'package:cliq/modules/keys/view/generate_key_view.dart';

class KeyCreationChoiceView extends HookConsumerWidget {
  const KeyCreationChoiceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    openImport() {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Commons.showResponsiveDialog(
          (_) => const CreateOrEditKeyView.create(),
          context: context,
        );
      });
    }

    openGenerate() {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Commons.showResponsiveDialog(
          (_) => const GenerateKeyView(),
          context: context,
        );
      });
    }

    final mutedStyle = context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    );

    return FScaffold(
      childPad: false,
      child: Padding(
        padding: const .symmetric(horizontal: 32, vertical: 20),
        child: LayoutBuilder(
          builder: (context, _) {
            return SizedBox.expand(
              child: Center(
                child: SizedBox(
                  width: 520,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      Text(
                        'keys_add'.tr(),
                        style: context.theme.typography.body.xl2,
                      ),
                      Text('keys_add_subtitle'.tr(), style: mutedStyle),
                      FButton(
                        variant: .outline,
                        prefix: const Icon(LucideIcons.folderOpen),
                        onPress: openImport,
                        child: Text('keys_import_existing'.tr()),
                      ),
                      FButton(
                        prefix: const Icon(LucideIcons.rotateCcwKey),
                        onPress: openGenerate,
                        child: Text('keys_generate_new'.tr()),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FButton(
                          variant: .ghost,
                          onPress: () => Navigator.of(context).pop(),
                          child: Text('cancel'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
