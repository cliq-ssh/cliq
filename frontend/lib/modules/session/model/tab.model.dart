import 'package:cliq/modules/connections/ui/connection_icon.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/page/new_tab.page.dart';
import 'package:cliq/modules/session/page/sftp_session.page.dart';
import 'package:cliq/modules/session/page/ssh_session.page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum TabContent({
  final bool canRename = true,
  final bool canPin = true,
  final bool canSplit = false,

  /// Whether this tab can only be opened once.
  final bool isSingleTab = false,
}) {
  /// The new tab page.
  newTab,

  /// The [SettingsPage].
  settings(canRename: false, canPin: false, isSingleTab: true),

  /// The [SshSessionPage] or a split view with multiple pages.
  /// Requires [Tab.session] to be set.
  ssh(canSplit: true),

  /// The [SftpSessionPage] or a split view with multiple pages.
  /// Requires [Tab.session] to be set.
  sftp(canSplit: true),
}

class Tab({
  required final String id,
  required final int windowId,

  /// The tab's currently displayed content
  var TabContent content = .newTab,

  // TODO: Split View
  /// A reference to the session associated with this tab.
  /// This is null if no session was yet created (i.e. the tab is empty/"new")
  var SshSession? session,

  /// Whether the tab is pinned and always at the start of the tab list
  var bool pinned = false,

  /// The tab's custom label, given by the user
  var String? customLabel,
}) {
  Widget? getIcon(BuildContext context) {
    return switch (content) {
      .settings => const Icon(LucideIcons.settings),
      .ssh || .sftp => ConnectionIcon.fromConnection(session!.connection),
      _ => null,
    };
  }

  /// Returns the effective label for the tab.
  /// If [customLabel] is set and the content allows renaming, it will be used.
  /// If not, it will be based on the [TabContent]
  String getEffectiveLabel(BuildContext context) {
    if (customLabel != null && content.canRename) {
      return customLabel!;
    }
    return switch (content) {
      .newTab => 'tab_new'.tr(context: context),
      .settings => 'settings'.tr(context: context),
      .ssh || .sftp => session!.getEffectiveTitle(context),
    };
  }

  Widget getEffectiveContent(BuildContext context) {
    return switch (content) {
      .newTab => const NewTabPage(),
      .settings => const SettingsPage(),
      .ssh => SshSessionPage(sessionId: session!.id),
      .sftp => SftpSessionPage(sessionId: session!.id),
    };
  }

  void dispose() => session?.dispose();
}
