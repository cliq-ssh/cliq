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

  void reorderTab(int currentIndex, int newIndex) {
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
}
