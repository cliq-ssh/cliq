import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class AbstractSettingsPage extends HookConsumerWidget {
  const AbstractSettingsPage({super.key});

  Widget buildBody(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FScaffold(
      header: FHeader.nested(
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: buildBody(context, ref),
    );
  }
}
