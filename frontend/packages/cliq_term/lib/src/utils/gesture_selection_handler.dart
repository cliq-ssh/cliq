import 'package:flutter/gestures.dart';

/// Handles pointer-based gesture selection for the terminal.
class GestureSelectionHandler {
  const GestureSelectionHandler._();

  /// Calculate the absolute row and column from a pointer position.
  ///
  /// [localPosition] - the local position of the pointer (relative to widget)
  /// [scrollOffset] - the current scroll offset
  /// [cellWidth] - the width of a single character cell
  /// [cellHeight] - the height of a single character cell
  /// [totalRows] - the total number of rows in the buffer
  /// [maxCols] - the maximum number of columns
  static (int row, int col) calculateAbsoluteCoordinates({
    required Offset localPosition,
    required double scrollOffset,
    required double cellWidth,
    required double cellHeight,
    required int totalRows,
    required int maxCols,
  }) {
    final absY = localPosition.dy + scrollOffset;
    final row = (absY / cellHeight).floor();
    final col = (localPosition.dx / cellWidth).floor();

    final absRow = row.clamp(0, totalRows - 1);
    final absCol = col.clamp(0, maxCols - 1);

    return (absRow, absCol);
  }
}
