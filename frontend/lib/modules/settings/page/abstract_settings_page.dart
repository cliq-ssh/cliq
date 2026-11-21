import 'package:cliq_grid/cliq_grid.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

abstract class const AbstractSettingsPage({super.key})
    extends HookConsumerWidget {
  String get title;
  Widget buildBody(BuildContext context, WidgetRef ref);

  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) {
    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Padding(padding: const .only(bottom: 32), child: body),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FScaffold(
      childPad: false,
      // FHeader for some reason adds a SafeArea, which creates a lot of unnecessary padding on mobile.
      header: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: FHeader.nested(
          title: FBreadcrumb(
            children: [
              FBreadcrumbItem(
                onPress: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text('settings'.tr()),
              ),
              FBreadcrumbItem(current: true, child: Text(title)),
            ],
          ),
          prefixes: [
            FButton.icon(
              variant: .outline,
              onPress: () => Navigator.of(context).pop(),
              child: const Icon(LucideIcons.arrowLeft),
            ),
          ],
        ),
      ),
      child: buildBodyWrapper(context, ref, buildBody(context, ref)),
    );
  }
}
