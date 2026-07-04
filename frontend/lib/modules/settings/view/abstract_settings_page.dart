import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

abstract class AbstractSettingsPage extends HookConsumerWidget {
  const AbstractSettingsPage({super.key});

  String get title;
  Widget buildBody(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FScaffold(
      header: FHeader.nested(
        title: FBreadcrumb(
          children: [
            FBreadcrumbItem(onPress: context.pop, child: Text('settings'.tr())),
            FBreadcrumbItem(current: true, child: Text(title)),
          ],
        ),
        prefixes: [
          FButton.icon(
            variant: .outline,
            onPress: () => context.pop(),
            child: Icon(LucideIcons.arrowLeft),
          ),
        ],
      ),
      child: Padding(
        padding: const .only(top: 24),
        child: buildBody(context, ref),
      ),
    );
  }
}
