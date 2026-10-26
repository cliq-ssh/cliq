class TerminalModesState({
  final bool isInsert = false,
  final bool isAutowrap = true,
  final bool isLineFeed = false,
  final Set<int> tabStops = const {},
}) {
  TerminalModesState copyWith({
    bool? isInsert,
    bool? isAutowrap,
    bool? isLineFeed,
    Set<int>? tabStops,
  }) {
    return TerminalModesState(
      isInsert: isInsert ?? this.isInsert,
      isAutowrap: isAutowrap ?? this.isAutowrap,
      isLineFeed: isLineFeed ?? this.isLineFeed,
      tabStops: tabStops ?? this.tabStops,
    );
  }
}
