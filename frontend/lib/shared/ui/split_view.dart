import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef SplitViewItemBuilder = Widget Function(BuildContext, FocusNode);

enum SplitViewDirection { horizontal, vertical }

class SplitViewItem<T extends Object> {
  final SplitViewItemBuilder builder;
  final (SplitViewDirection, bool, SplitViewItem<T>)? split;
  final Function(SplitViewItem<T>, T, SplitViewDirection, bool)? onDrop;
  final FocusNode focusNode = FocusNode();

  SplitViewItem({required this.builder, this.split, this.onDrop});

  void dispose() {
    focusNode.dispose();
    split?.$3.dispose();
  }

  SplitViewItem<T> copyWith({
    SplitViewItemBuilder? builder,
    (SplitViewDirection, bool, SplitViewItem<T>)? split,
    Function(SplitViewItem<T>, T, SplitViewDirection, bool)? onDrop,
  }) {
    return SplitViewItem<T>(
      builder: builder ?? this.builder,
      split: split ?? this.split,
      onDrop: onDrop ?? this.onDrop,
    );
  }
}

class SplitView<T extends Object> extends StatefulHookConsumerWidget {
  final SplitViewItem<T> parent;
  final double spacing;

  const SplitView({super.key, required this.parent, this.spacing = 8.0});

  @override
  ConsumerState<SplitView> createState() => SplitViewState<T>();

  SplitViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<SplitViewState<T>>();
  }
}

class SplitViewState<T extends Object> extends ConsumerState<SplitView<T>> {
  @override
  void dispose() {
    widget.parent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SplitViewContainer<T>(
      index: 0,
      item: widget.parent,
      isSingle: widget.parent.split == null,
      spacing: widget.spacing,
    );
  }
}

class _SplitViewContainer<T extends Object> extends HookConsumerWidget {
  final int index;
  final SplitViewItem<T> item;
  final double spacing;
  final bool isSingle;

  const _SplitViewContainer({
    required this.index,
    required this.item,
    required this.spacing,
    this.isSingle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDragZone = useState<(SplitViewDirection, bool)?>(null);

    (SplitViewDirection, bool) calculateDragZone(
      Offset position,
      BoxConstraints constraints,
    ) {
      final distLeft = position.dx;
      final distRight = constraints.maxWidth - position.dx;
      final distTop = position.dy;
      final distBottom = constraints.maxHeight - position.dy;

      final min = [
        distLeft,
        distRight,
        distTop,
        distBottom,
      ].reduce((a, b) => a < b ? a : b);

      // get the closest edge
      if (min == distTop) {
        return (.horizontal, true);
      }
      if (min == distBottom) {
        return (.horizontal, false);
      }
      if (min == distLeft) {
        return (.vertical, true);
      }
      return (.vertical, false);
    }

    buildDragZoneContainer() {
      return Container(color: context.theme.colors.primary.withOpacity(0.5));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<T>(
          onWillAcceptWithDetails: (details) {
            activeDragZone.value = calculateDragZone(
              details.offset,
              constraints,
            );
            return true;
          },
          onAcceptWithDetails: (details) {
            final zone = activeDragZone.value;
            activeDragZone.value = null;
            if (zone == null) return;
            item.onDrop?.call(item, details.data, zone.$1, zone.$2);

            activeDragZone.value = null;
          },
          onMove: (details) {
            activeDragZone.value = calculateDragZone(
              details.offset,
              constraints,
            );
          },
          onLeave: (data) => activeDragZone.value = null,
          builder: (context, allowed, rejected) {
            Widget child = item.builder(context, item.focusNode);

            if (item.split != null) {
              final split = item.split!;
              child = split.$1 == .horizontal
                  ? Column(
                      spacing: spacing,
                      children: [
                        child,
                        _SplitViewContainer<T>(
                          index: index + 1,
                          item: split.$3,
                          spacing: spacing,
                        ),
                      ],
                    )
                  : Row(
                      spacing: spacing,
                      children: [
                        child,
                        _SplitViewContainer<T>(
                          index: index + 1,
                          item: split.$3,
                          spacing: spacing,
                        ),
                      ],
                    );
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    padding: isSingle ? .zero : .all(spacing / 2),
                    child: child,
                  ),
                ),
                if (activeDragZone.value != null)
                  if (activeDragZone.value!.$1 == .horizontal)
                    Positioned(
                      bottom: activeDragZone.value!.$2
                          ? constraints.maxHeight / 2 - spacing
                          : 0,
                      top: activeDragZone.value!.$2
                          ? 0
                          : constraints.maxHeight / 2 - spacing,
                      left: 0,
                      right: 0,
                      child: buildDragZoneContainer(),
                    )
                  else
                    Positioned(
                      right: activeDragZone.value!.$2
                          ? constraints.maxWidth / 2 - spacing
                          : 0,
                      left: activeDragZone.value!.$2
                          ? 0
                          : constraints.maxWidth / 2 - spacing,
                      top: 0,
                      bottom: 0,
                      child: buildDragZoneContainer(),
                    ),
              ],
            );
          },
        );
      },
    );
  }
}
