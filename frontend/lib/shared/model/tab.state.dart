import 'package:cliq/shared/model/tab.model.dart';

class const TabState({
  required final List<Tab> tabs,
  required final Map<int, String> selectedTabs,
}) {
  const new initial() : this(tabs: const [], selectedTabs: const {});

  Tab? findById(String? id) {
    if (id == null) return null;
    return tabs.where((t) => t.id == id).firstOrNull;
  }

  /// Gets the tabs for the given window id.
  List<Tab> getTabsByWindowId(int windowId) =>
      tabs.where((t) => t.windowId == windowId).toList();

  /// Gets the selected tab id for the given window id.
  String? getSelectedTabIdByWindowId(int windowId) => selectedTabs[windowId];

  TabState copyWith({List<Tab>? tabs, Map<int, String>? selectedTabs}) {
    return TabState(
      tabs: tabs ?? this.tabs,
      selectedTabs: selectedTabs ?? this.selectedTabs,
    );
  }
}
