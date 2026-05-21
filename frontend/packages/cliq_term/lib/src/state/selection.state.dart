class SelectionState {
  final bool active;
  final int? startRow;
  final int? startCol;
  final int? endRow;
  final int? endCol;

  const SelectionState({
    this.active = false,
    this.startRow,
    this.startCol,
    this.endRow,
    this.endCol,
  });

  /// Whether the selection is active and has valid start and end coordinates.
  bool get isSelectionActive =>
      active &&
      startRow != null &&
      startCol != null &&
      endRow != null &&
      endCol != null;

  SelectionState copyWith({
    bool? active,
    int? startRow,
    int? startCol,
    int? endRow,
    int? endCol,
  }) {
    return SelectionState(
      active: active ?? this.active,
      startRow: startRow ?? this.startRow,
      startCol: startCol ?? this.startCol,
      endRow: endRow ?? this.endRow,
      endCol: endCol ?? this.endCol,
    );
  }
}
