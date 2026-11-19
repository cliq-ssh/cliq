import 'package:cliq/modules/session/page/sftp_session.page.dart';
import 'package:cliq/modules/session/page/ssh_session.page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/shared/page/new_tab.page.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

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
  var String? sessionId,

  /// Whether the tab is pinned and always at the start of the tab list
  var bool pinned = false,

  /// The tab's custom label, given by the user
  var String? customLabel,
}) {
  Widget getEffectiveContent(BuildContext context) {
    return switch (content) {
      .newTab => NewTabPage(tabId: id),
      .settings => const SettingsPage(),
      .ssh => SshSessionPage(tab: this, sessionId: sessionId!),
      .sftp => SftpSessionPage(tab: this, sessionId: sessionId!),
    };
  }
}
