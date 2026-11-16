import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/model/tab.state.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v7.dart';

final tabProvider = NotifierProvider(TabNotifier.new);

class TabNotifier extends Notifier<TabState> {
  static const UuidV7 v7 = UuidV7();

  @override
  TabState build() => const .initial();

  /// Opens a new tab in the current window and attempts to navigate to it.
  void openNewAndMaybeGo(NavigationShellState navigationState, int windowId) {
    final newTab = Tab(id: v7.generate(), windowId: windowId);
    state = state.copyWith(tabs: [...state.tabs, newTab]);

    select(navigationState, windowId, newTab.id);
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

    // dispose
    final tab = state.tabs.firstWhere((t) => t.id == tabId);
    tab.dispose();

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
