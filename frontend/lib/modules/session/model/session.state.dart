import 'package:cliq/modules/session/model/tab.model.dart';

class SessionState {
  /// A list of active session tabs, where each tab can contain multiple ShellSessions, e.g., for split view.
  final List<SessionTab> activeTabs;

  /// The ID of the currently selected session tab. This corresponds to a key in [activeTabs].
  final String? selectedTabId;

  /// Maps session IDs to their currently active page index in the PageView.
  final Map<String, int> tabPageIndices;

  const SessionState.initial()
    : activeTabs = const [],
      selectedTabId = null,
      tabPageIndices = const {};

  const SessionState({
    required this.activeTabs,
    required this.selectedTabId,
    this.tabPageIndices = const {},
  });

  /// Gets the [SessionTab] for the currently selected tab id, or null if no tab is selected.
  SessionTab? get selectedSession {
    if (selectedTabId == null) {
      return null;
    }

    for (final tab in activeTabs) {
      if (tab.id == selectedTabId) {
        return tab;
      }
    }
    return null;
  }

  /// Gets the currently active page index for the selected tab, or null if no tab is selected.
  int? get selectedTabPageIndex {
    if (selectedTabId == null) {
      return null;
    }
    return tabPageIndices[selectedTabId!] ?? 0;
  }

  SessionState copyWith({
    List<SessionTab>? activeTabs,
    String? selectedTabId,
    Map<String, int>? tabPageIndices,
  }) {
    return SessionState(
      activeTabs: activeTabs ?? this.activeTabs,
      selectedTabId: selectedTabId ?? this.selectedTabId,
      tabPageIndices: tabPageIndices ?? this.tabPageIndices,
    );
  }
}
