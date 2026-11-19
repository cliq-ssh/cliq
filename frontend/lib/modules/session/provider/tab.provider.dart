import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/model/tab.state.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v7.dart';

final tabProvider = NotifierProvider(TabNotifier.new);

class TabNotifier extends Notifier<TabState> {
  static const UuidV7 v7 = UuidV7();

  @override
  TabState build() => const .initial();

  /// Opens a new tab in the current window and attempts to navigate to it.
  /// Returns the tab id of the newly opened tab or null if the tab already exists.
  String? openNewAndMaybeGo(
    NavigationShellState navigationState,
    int windowId, {
    TabContent content = .newTab,
    SshSession? session,
  }) {
    if (content.isSingleTab && state.tabs.any((t) => t.content == content)) {
      // focus the first tab of this content instead
      final firstTab = state.tabs.firstWhere((t) => t.content == content);
      select(navigationState, windowId, firstTab.id);
      return null;
    }

    final newTab = Tab(
      id: v7.generate(),
      windowId: windowId,
      content: content,
      sessionId: session?.id,
    );
    state = state.copyWith(tabs: [...state.tabs, newTab]);

    select(navigationState, windowId, newTab.id);
    return newTab.id;
  }

  /// Switches to a ssh/sftp view with the given connection.
  void goSsh(String tabId, SshSession session) {
    _updateTab(tabId, (tab) {
      tab.sessionId = session.id;
      return tab.content = session.type == .sftp ? .sftp : .ssh;
    });
  }

  /// Selects the tab with the given id.
  void select(
    NavigationShellState navigationState,
    int windowId,
    String tabId,
  ) {
    // navigate to session branch
    navigationState.goToSessionBranch();

    final newSelectedTabs = Map.of(state.selectedTabs);
    newSelectedTabs[windowId] = tabId;
    state = state.copyWith(selectedTabs: newSelectedTabs);
  }

  /// Unselects the tab with the given id.
  void unselect(String tabId) {
    final newSelectedTabs = Map.of(state.selectedTabs);
    newSelectedTabs.removeWhere((_, id) => id == tabId);
    state = state.copyWith(selectedTabs: newSelectedTabs);
  }

  /// Pins the tab with the given id.
  /// Unpins the tab if [unpin] is true.
  ///
  /// This also re-orders the tab to be in the front (index 0)
  void pin(String tabId, {bool unpin = false}) {
    _updateTab(tabId, (tab) => tab.pinned = !unpin);
    // re-order tab to be in the front
    reorder(_getIndexByTabId(tabId), 0);
  }

  /// Renames the tab with the given id.
  /// Set [newLabel] to null to remove the custom label.
  void rename(String tabId, String? newLabel) {
    _updateTab(tabId, (tab) => tab.customLabel = newLabel);
  }

  /// Re-orders the tabs in the given index to the new index.
  void reorder(int currentIndex, int newIndex) {
    final newTabs = List.of(state.tabs);
    final tab = newTabs.removeAt(currentIndex);
    newTabs.insert(newIndex, tab);
    state = state.copyWith(tabs: newTabs);
  }

  /// Closes the tab with the given id.
  void close(String tabId) {
    unselect(tabId);
    final tab = state.tabs.firstWhere((t) => t.id == tabId);

    /// Dispose session
    if (tab.sessionId != null) {
      ref.read(sessionProvider.notifier).removeAndDispose(tab.sessionId!);
    }

    final newTabs = List.of(state.tabs);
    newTabs.removeWhere((t) => t.id == tabId);
    state = state.copyWith(tabs: newTabs);
  }

  int _getIndexByTabId(String tabId) =>
      state.tabs.indexWhere((t) => t.id == tabId);

  /// Reactively updates the tab by applying the [update] function and then updating the state.
  void _updateTab(String tabId, Function(Tab) update) {
    final index = _getIndexByTabId(tabId);
    final newTabs = List.of(state.tabs);
    update(newTabs[index]);
    state = state.copyWith(tabs: newTabs);
  }
}
