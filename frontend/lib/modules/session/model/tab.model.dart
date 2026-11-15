import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';

class Tab({
  required final String id,
  required final int windowId,

  // TODO: Split View
  /// A reference to the session associated with this tab.
  /// This is null if no session was yet created (i.e. the tab is empty/"new")
  var SshSession? session,
}) {
  String getEffectiveLabel(BuildContext context) =>
      session?.getEffectiveTitle(context) ?? 'new_tab'.tr(context: context);

  void dispose() => session?.dispose();
}
