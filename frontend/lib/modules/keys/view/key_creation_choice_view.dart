import 'package:cliq/shared/utils/commons.dart';
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
        Commons.showResponsiveDialog((_) => const CreateOrEditKeyView.create());
      });
    }

    openGenerate() {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Commons.showResponsiveDialog((_) => const GenerateKeyView());
      });
    }

    final mutedStyle = context.theme.typography.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text('Add Key', style: context.theme.typography.xl2),
          Text(
            'Choose whether you want to import an existing SSH key or generate a new one.',
            style: mutedStyle,
          ),
          FButton(
            variant: .outline,
            prefix: const Icon(LucideIcons.folderOpen),
            onPress: openImport,
            child: const Text('Import Existing Key'),
          ),
          FButton(
            prefix: const Icon(Icons.vpn_key),
            onPress: openGenerate,
            child: const Text('Generate New Key'),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              variant: .ghost,
              onPress: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
