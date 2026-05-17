import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SplitViewDirection { horizontal, vertical }

/// The minimum extent of a split leaf. This is to prevent the leaf from being resized to a size that is too small to be usable.
const _kMinExtent = 80.0;

/// The thickness of the divider that can be dragged to resize the leaves.
const _kDividerExtent = 6.0;

sealed class SplitNode<T extends Object> {
  void dispose();
}

class SplitLeaf<T extends Object> extends SplitNode<T> {
  final T value;
  final Widget Function(BuildContext, FocusNode) builder;
  final FocusNode focusNode = FocusNode();

  SplitLeaf({required this.value, required this.builder});

  @override
  void dispose() => focusNode.dispose();
}

class SplitBranch<T extends Object> extends SplitNode<T> {
  final SplitViewDirection direction;
  final ValueNotifier<double> ratio = ValueNotifier(0.5);
  SplitNode<T> first;
  SplitNode<T> second;

  SplitBranch({
    required this.direction,
    required this.first,
    required this.second,
  });

  @override
  void dispose() {
    ratio.dispose();
    first.dispose();
    second.dispose();
  }
}

abstract class _NodeWidget<T extends Object> extends HookConsumerWidget {
  final bool Function(SplitLeaf<T> target, T dropped) canDrop;
  final void Function(SplitLeaf<T>, T, SplitViewDirection, bool) onDrop;
  final Color borderColor;
  final Color focusedBorderColor;

  final bool showBorder;

  const _NodeWidget({
    required super.key,
    required this.canDrop,
    required this.onDrop,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.showBorder,
  });
}

class SplitView<T extends Object> extends HookConsumerWidget {
  final SplitNode<T> root;
  final bool Function(SplitLeaf<T> target, T dropped) canDrop;
  final void Function(SplitLeaf<T>, T, SplitViewDirection, bool) onDrop;
  final Color borderColor;
  final Color focusedBorderColor;

  const SplitView({
    super.key,
    required this.root,
    required this.canDrop,
    required this.onDrop,
    required this.borderColor,
    required this.focusedBorderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SplitNodeWidget<T>(
      node: root,
      canDrop: canDrop,
      onDrop: onDrop,
      borderColor: borderColor,
      focusedBorderColor: focusedBorderColor,
      showBorder: root is SplitBranch<T>,
    );
  }
}

class _SplitNodeWidget<T extends Object> extends _NodeWidget<T> {
  final SplitNode<T> node;

  const _SplitNodeWidget({
    super.key,
    required super.canDrop,
    required super.onDrop,
    required super.borderColor,
    required super.focusedBorderColor,
    required super.showBorder,
    required this.node,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (node) {
      SplitLeaf<T>() => _LeafNodeWidget<T>(
        leaf: node as SplitLeaf<T>,
        canDrop: canDrop,
        onDrop: onDrop,
        borderColor: borderColor,
        focusedBorderColor: focusedBorderColor,
        showBorder: showBorder,
      ),
      SplitBranch<T>() => _BranchNodeWidget<T>(
        branch: node as SplitBranch<T>,
        canDrop: canDrop,
        onDrop: onDrop,
        borderColor: borderColor,
        focusedBorderColor: focusedBorderColor,
        showBorder: showBorder,
      ),
    };
  }
}

class _LeafNodeWidget<T extends Object> extends _NodeWidget<T> {
  final SplitLeaf<T> leaf;

  const _LeafNodeWidget({
    super.key,
    required super.canDrop,
    required super.onDrop,
    required super.borderColor,
    required super.focusedBorderColor,
    required super.showBorder,
    required this.leaf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDragZone = useState<(SplitViewDirection, bool)?>(null);
    final isFocused = leaf.focusNode.hasFocus;
    return LayoutBuilder(
      builder: (context, constraints) {
        (SplitViewDirection, bool) calculateZone(Offset global) {
          final p = (context.findRenderObject() as RenderBox).globalToLocal(
            global,
          );
          final distances = [
            p.dy,
            constraints.maxHeight - p.dy,
            p.dx,
            constraints.maxWidth - p.dx,
          ];
          final i = distances.indexOf(
            distances.reduce((a, b) => a < b ? a : b),
          );
          return (i < 2 ? .horizontal : .vertical, i.isEven);
        }

        return DragTarget<T>(
          onWillAcceptWithDetails: (d) {
            if (!canDrop(leaf, d.data)) {
              activeDragZone.value = null;
              return false;
            }
            activeDragZone.value = calculateZone(d.offset);
            return true;
          },
          onMove: (d) {
            if (!canDrop(leaf, d.data)) {
              activeDragZone.value = null;
              return;
            }
            activeDragZone.value = calculateZone(d.offset);
          },
          onLeave: (_) => activeDragZone.value = null,
          onAcceptWithDetails: (d) {
            final zone = activeDragZone.value;
            activeDragZone.value = null;
            if (zone != null) onDrop(leaf, d.data, zone.$1, zone.$2);
          },
          builder: (_, _, _) => Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: showBorder
                        ? Border.all(
                            color: isFocused ? focusedBorderColor : borderColor,
                            width: 1,
                          )
                        : null,
                  ),
                  child: leaf.builder(context, leaf.focusNode),
                ),
              ),
              if (activeDragZone.value != null)
                _DropOverlay(
                  zone: activeDragZone.value!,
                  constraints: constraints,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BranchNodeWidget<T extends Object> extends _NodeWidget<T> {
  final SplitBranch<T> branch;

  const _BranchNodeWidget({
    super.key,
    required super.canDrop,
    required super.onDrop,
    required super.borderColor,
    required super.focusedBorderColor,
    required super.showBorder,
    required this.branch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = useValueListenable(branch.ratio);
    final isH = branch.direction == SplitViewDirection.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final total =
            (isH ? constraints.maxHeight : constraints.maxWidth) -
            _kDividerExtent;
        final firstExtent = (ratio * total).clamp(
          _kMinExtent,
          total - _kMinExtent,
        );
        final secondExtent = total - firstExtent;

        Widget sized(SplitNode<T> node, double extent) => SizedBox(
          width: isH ? constraints.maxWidth : extent,
          height: isH ? extent : constraints.maxHeight,
          child: _SplitNodeWidget<T>(
            node: node,
            canDrop: canDrop,
            onDrop: onDrop,
            borderColor: borderColor,
            focusedBorderColor: focusedBorderColor,
            showBorder: showBorder,
          ),
        );

        final divider = MouseRegion(
          cursor: isH
              ? SystemMouseCursors.resizeUpDown
              : SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (d) {
              final delta = isH ? d.delta.dy : d.delta.dx;
              branch.ratio.value = ((firstExtent + delta) / total).clamp(
                _kMinExtent / total,
                (total - _kMinExtent) / total,
              );
            },
            child: SizedBox(
              width: isH ? constraints.maxWidth : _kDividerExtent,
              height: isH ? _kDividerExtent : constraints.maxHeight,
            ),
          ),
        );

        return isH
            ? Column(
                children: [
                  sized(branch.first, firstExtent),
                  divider,
                  sized(branch.second, secondExtent),
                ],
              )
            : Row(
                children: [
                  sized(branch.first, firstExtent),
                  divider,
                  sized(branch.second, secondExtent),
                ],
              );
      },
    );
  }
}

class _DropOverlay extends StatelessWidget {
  final (SplitViewDirection, bool) zone;
  final BoxConstraints constraints;

  const _DropOverlay({required this.zone, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colors.primary.withValues(alpha: 0.35);
    final (dir, isFirst) = zone;
    return dir == SplitViewDirection.horizontal
        ? Positioned(
            top: isFirst ? 0 : constraints.maxHeight / 2,
            bottom: isFirst ? constraints.maxHeight / 2 : 0,
            left: 0,
            right: 0,
            child: Container(color: color),
          )
        : Positioned(
            left: isFirst ? 0 : constraints.maxWidth / 2,
            right: isFirst ? constraints.maxWidth / 2 : 0,
            top: 0,
            bottom: 0,
            child: Container(color: color),
          );
  }
}
