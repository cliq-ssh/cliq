import 'package:cliq/shared/ui/horizontal_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const PasswordDialog({
  super.key,
  required final FDialogStyle style,
  required final Animation<double> animation,
}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();

    return HorizontalDialog(
      style: style,
      animation: animation,
      title: const Text('This file is password protected'),
      body: Column(
        spacing: 16,
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          const Text(
            'To continue, please enter the password to unlock the file.',
          ),
          FTextFormField.password(
            control: .managed(controller: passwordController),
          ),
        ],
      ),
      actions: [
        FButton(
          variant: .outline,
          child: const Text('Cancel'),
          onPress: () => Navigator.of(context).pop(),
        ),
        FButton(
          variant: .primary,
          child: const Text('Submit'),
          onPress: () => Navigator.of(context).pop(passwordController.text),
        ),
      ],
    );
  }
}
