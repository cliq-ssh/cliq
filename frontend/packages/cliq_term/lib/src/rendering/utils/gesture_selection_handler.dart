import 'package:flutter/gestures.dart';

/// Handles pointer-based gesture selection for the terminal.
class GestureSelectionHandler {
  const GestureSelectionHandler._();

  /// Calculate the visible row and column from a pointer position.
  ///
  /// [localPosition] - the local position of the pointer (relative to widget)
  /// [scrollOffset] - the current scroll offset
  /// [cellWidth] - the width of a single character cell
  /// [cellHeight] - the height of a single character cell
  /// [currentScrollback] - the current scrollback offset in the buffer
  /// [maxRows] - the maximum number of visible rows
  /// [maxCols] - the maximum number of visible columns
  static (int row, int col) calculateVisibleCoordinates({
    required Offset localPosition,
    required double scrollOffset,
    required double cellWidth,
    required double cellHeight,
    required int currentScrollback,
    required int maxRows,
    required int maxCols,
  }) {
    final absY = localPosition.dy + scrollOffset;
    final row = (absY / cellHeight).floor() - currentScrollback;
    final col = (localPosition.dx / cellWidth).floor();

    final visRow = row.clamp(0, maxRows - 1);
    final visCol = col.clamp(0, maxCols - 1);

    return (visRow, visCol);
  }
}
