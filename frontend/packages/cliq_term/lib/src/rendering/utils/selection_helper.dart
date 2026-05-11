/// Helper class for selection normalization and coordinate mapping.
class SelectionHelper {
  /// Normalizes selection coordinates so start <= end for both rows and columns.
  /// Returns a normalized selection [SelectionBounds] with ordered coordinates.
  static SelectionBounds normalize({
    required int startRow,
    required int startCol,
    required int endRow,
    required int endCol,
    required int maxRows,
    required int maxCols,
  }) {
    var sr = startRow.clamp(0, maxRows - 1);
    var er = endRow.clamp(0, maxRows - 1);
    var sc = startCol.clamp(0, maxCols - 1);
    var ec = endCol.clamp(0, maxCols - 1);

    // normalize row order
    if (sr > er) {
      final t = sr;
      sr = er;
      er = t;
      // swap columns too when reversing rows
      final tc = sc;
      sc = ec;
      ec = tc;
    }

    // normalize column order for same-row selections
    if (sr == er && sc > ec) {
      final t = sc;
      sc = ec;
      ec = t;
    }

    return SelectionBounds(startRow: sr, startCol: sc, endRow: er, endCol: ec);
  }

  /// Get the start and end coordinates for a row within the selection.
  /// For multi-row selections, intermediate rows span full width (0 to maxCols-1).
  static RowSelection getRowSelection({
    required int row,
    required SelectionBounds bounds,
    required int maxCols,
  }) {
    if (row < bounds.startRow || row > bounds.endRow) {
      return RowSelection(start: 0, end: 0, isEmpty: true);
    }

    if (bounds.startRow == bounds.endRow) {
      // single row selection
      return RowSelection(
        start: bounds.startCol,
        end: bounds.endCol,
        isEmpty: false,
      );
    }

    if (row == bounds.startRow) {
      // first row of multi-row selection
      return RowSelection(
        start: bounds.startCol,
        end: maxCols - 1,
        isEmpty: false,
      );
    }

    if (row == bounds.endRow) {
      // last row of multi-row selection
      return RowSelection(start: 0, end: bounds.endCol, isEmpty: false);
    }

    // middle rows span full width
    return RowSelection(start: 0, end: maxCols - 1, isEmpty: false);
  }
}

/// Represents normalized selection boundaries.
class SelectionBounds {
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;

  SelectionBounds({
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
  });

  bool get isEmpty => startRow == endRow && startCol == endCol;
}

/// Represents the column range for a single row within a selection.
class RowSelection {
  final int start;
  final int end;
  final bool isEmpty;

  RowSelection({required this.start, required this.end, required this.isEmpty});
}
