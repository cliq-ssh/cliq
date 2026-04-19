import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PasswordDialog extends HookConsumerWidget {
  final FDialogStyle style;
  final Animation<double> animation;

  const PasswordDialog({
    super.key,
    required this.style,
    required this.animation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();

    return FDialog(
      style: style,
      animation: animation,
      direction: Axis.horizontal,
      title: const Text('This file is password protected'),
      body: Column(
        spacing: 16,
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text('To continue, please enter the password to unlock the file.'),
          FTextFormField.password(
            control: .managed(controller: passwordController),
          ),
        ],
      ),
      actions: [
        FButton(
          variant: .outline,
          child: Text('Cancel'),
          onPress: () => Navigator.of(context).pop(),
        ),
        FButton(
          variant: .primary,
          child: Text('Submit'),
          onPress: () => Navigator.of(context).pop(passwordController.text),
        ),
      ],
    );
  }
}
