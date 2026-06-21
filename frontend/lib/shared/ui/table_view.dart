import 'dart:math' as math;

import 'package:flutter/material.dart' hide LicensePage;
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const _kDividerThickness = 1.0;
const _kHeaderHeight = 48.0;
const _kRowHeight = 48.0;
const _kHeaderPadding = EdgeInsets.symmetric(horizontal: 12);
const _kRowPadding = EdgeInsets.symmetric(horizontal: 12);
const _kMinColumnWidth = 80.0;

class TableViewCell {
  final Widget child;
  const TableViewCell({required this.child});
}

class TableViewRow {
  final List<TableViewCell> cells;
  const TableViewRow({required this.cells});
}

class _TableRow extends StatefulWidget {
  final List<TableViewCell> cells;
  final List<double> widths;
  final double height;
  final EdgeInsets padding;

  /// If true, every cell can receive focus individually. If false, only the entire row can be focused.
  final bool perCellFocus;

  final bool isSelected;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;

  final void Function(int columnIndex, double delta)? onResize;
  final ValueChanged<int?>? onTap;
  final ValueChanged<int?>? onDoubleTap;

  const _TableRow({
    required this.cells,
    required this.widths,
    required this.height,
    required this.padding,
    this.perCellFocus = false,
    this.isSelected = false,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.onResize,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  int? _focused;

  static const double _resizeHandleWidth = 18;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focused = null;
  }

  @override
  void didUpdateWidget(covariant _TableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cells.length != widget.cells.length) {
      _focused = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = context.theme.colors.border;
    final focusColor = context.theme.colors.primary;

    onTap(int index) {
      widget.onTap?.call(index);
      setState(() => _focused = null);
    }

    onDoubleTap(int index) {
      widget.onDoubleTap?.call(index);
      setState(() => _focused = null);
    }

    buildFocusWrapper(Widget child, int index) {
      return Stack(
        children: [
          Semantics(
            button: true,
            child: FocusableActionDetector(
              mouseCursor: SystemMouseCursors.click,
              onShowFocusHighlight: (value) {
                if (!mounted) return;
                if (value) {
                  setState(() => _focused = index);
                  return;
                }
                setState(() => _focused = null);
              },
              shortcuts: const {
                SingleActivator(.enter): ActivateIntent(),
                SingleActivator(.space): ActivateIntent(),
              },
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (intent) {
                    onDoubleTap(index);
                    return null;
                  },
                ),
              },
              child: child,
            ),
          ),
          if (_focused == index)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: focusColor, width: 1.5),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    buildCell(int index) {
      final cell = widget.cells[index];
      final isLast = index == widget.cells.length - 1;
      final hasResizeHandle = widget.onResize != null && !isLast;

      final effectivePadding = hasResizeHandle
          ? widget.padding.copyWith(
              right: widget.padding.right + _resizeHandleWidth,
            )
          : widget.padding;

      Widget child = SizedBox(
        width: widget.widths[index],
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            border: Border(
              right: isLast
                  ? BorderSide.none
                  : BorderSide(width: _kDividerThickness, color: borderColor),
              bottom: BorderSide(width: _kDividerThickness, color: borderColor),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: .opaque,
                  onTap: () => onTap(index),
                  onDoubleTap: () => onDoubleTap(index),
                  child: Padding(
                    padding: effectivePadding,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: cell.child,
                    ),
                  ),
                ),
              ),
              if (hasResizeHandle)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        widget.onResize!(index, details.delta.dx);
                      },
                      child: SizedBox(
                        width: _resizeHandleWidth,
                        child: Center(
                          child: Icon(
                            LucideIcons.gripVertical,
                            size: 14,
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

      if (widget.perCellFocus) {
        child = buildFocusWrapper(child, index);
      }

      return child;
    }

    Widget baseRow = Container(
      color: widget.isSelected
          ? widget.selectedBackgroundColor
          : widget.backgroundColor,
      child: Row(children: List.generate(widget.cells.length, buildCell)),
    );

    // focus wrapper on the entire row if perCellFocus is false
    if (!widget.perCellFocus && widget.onTap != null) {
      baseRow = buildFocusWrapper(baseRow, 0);
    }

    return baseRow;
  }
}

class TableView extends StatefulWidget {
  final List<TableViewCell> columns;
  final int rowCount;
  final TableViewRow? Function(BuildContext context, int index) rowBuilder;
  final ValueChanged<int>? onColumnTap;
  final ValueChanged<int>? onRowTap;
  final ValueChanged<int>? onRowDoubleTap;
  final List<int>? selectedRows;
  final Color? backgroundColor;

  const TableView.builder({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowBuilder,
    this.onColumnTap,
    this.onRowTap,
    this.onRowDoubleTap,
    this.selectedRows,
    this.backgroundColor,
  });

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  List<double>? _columnWidths;
  bool _manualResized = false;

  void _resizeColumn(int columnIndex, double delta) {
    final widths = _columnWidths;
    if (widths == null) return;
    if (columnIndex < 0 || columnIndex >= widths.length - 1) return;

    final left = widths[columnIndex] + delta;
    final right = widths[columnIndex + 1] - delta;

    if (left < _kMinColumnWidth || right < _kMinColumnWidth) {
      return;
    }

    setState(() {
      _manualResized = true;
      widths[columnIndex] = left;
      widths[columnIndex + 1] = right;
    });
  }

  @override
  void didUpdateWidget(covariant TableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns.length != widget.columns.length) {
      _columnWidths = null;
      _manualResized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = widget.columns.length;
        assert(columnCount > 0, 'TableView requires at least one column.');

        final viewportWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : columnCount * _kMinColumnWidth;

        final minTableWidth = columnCount * _kMinColumnWidth;

        if (_columnWidths == null || _columnWidths!.length != columnCount) {
          _columnWidths = List<double>.filled(
            columnCount,
            math.max(viewportWidth, minTableWidth) / columnCount,
          );
          _manualResized = false;
        }

        if (!_manualResized) {
          final autoWidth = math.max(viewportWidth, minTableWidth);
          _columnWidths = List<double>.filled(
            columnCount,
            autoWidth / columnCount,
          );
        } else {
          final sum = _columnWidths!.fold<double>(0, (a, b) => a + b);
          if (sum < viewportWidth) {
            final scale = viewportWidth / sum;
            _columnWidths = _columnWidths!
                .map((w) => w * scale)
                .toList(growable: false);
          }
        }

        final widths = List<double>.from(_columnWidths!);
        final tableWidth = math.max(
          viewportWidth,
          widths.fold<double>(0, (a, b) => a + b),
        );

        final backgroundColor =
            widget.backgroundColor ?? context.theme.colors.background;
        final selectedBackgroundColor = context.theme.colors.primary.withValues(
          alpha: 0.2,
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: CustomScrollView(
              slivers: [
                PinnedHeaderSliver(
                  child: _TableRow(
                    cells: widget.columns,
                    widths: widths,
                    height: _kHeaderHeight,
                    padding: _kHeaderPadding,
                    perCellFocus: true,
                    onTap: (index) => widget.onColumnTap?.call(index!),
                    onResize: _resizeColumn,
                    backgroundColor: backgroundColor,
                  ),
                ),
                SliverList.builder(
                  itemCount: widget.rowCount,
                  itemBuilder: (context, index) {
                    final row = widget.rowBuilder(context, index);
                    if (row == null) {
                      return const SizedBox.shrink();
                    }

                    return _TableRow(
                      cells: row.cells,
                      widths: widths,
                      height: _kRowHeight,
                      padding: _kRowPadding,
                      onTap: (_) => widget.onRowTap?.call(index),
                      onDoubleTap: (_) => widget.onRowDoubleTap?.call(index),
                      isSelected: widget.selectedRows?.contains(index) ?? false,
                      backgroundColor: backgroundColor,
                      selectedBackgroundColor: selectedBackgroundColor,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
