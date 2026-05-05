import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The extent of the divider's interactive area.
const _kDividerExtent = 16.0;

enum SplitLayout { horizontal, vertical, topOneBottomTwo, leftTwoRightOne }

typedef SplitViewItemBuilder = Widget Function(BuildContext, FocusNode);

class SplitView extends StatefulHookConsumerWidget {
  final List<SplitViewItemBuilder> itemBuilder;

  /// Controls the layout for 2 and 3 child configurations.
  /// This has no effect when there are 1 or 4 children.
  final SplitLayout layout;
  final double spacing;

  const SplitView({
    super.key,
    required this.itemBuilder,
    this.layout = .horizontal,
    this.spacing = 0.0,
  }) : assert(
         itemBuilder.length > 0 && itemBuilder.length <= 4,
         'SplitView supports only 1 to 4 children',
       );

  @override
  ConsumerState<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends ConsumerState<SplitView> {
  @override
  Widget build(BuildContext context) {
    final ratio1 = useState(.5); // first divider in every layout
    final ratio2 = useState(.5); // inner split
    final ratio3 = useState(.5); // tertiary inner split (4 child bottom row)

    final focusNodes = useMemoized(
      () => List.generate(4, (i) => FocusNode(debugLabel: 'SplitViewChild#$i')),
      [],
    );

    useEffect(() {
      ratio1.value = .5;
      ratio2.value = .5;
      ratio3.value = .5;
      return null;
    }, [widget.itemBuilder.length]);

    useEffect(() {
      void rebuild() => setState(() {});

      for (final fn in focusNodes) {
        fn.addListener(rebuild);
      }

      return () {
        for (final fn in focusNodes) {
          fn.removeListener(rebuild);
          fn.dispose();
        }
      };
    }, []);

    // no need to build the layout if there's only one child
    if (widget.itemBuilder.length == 1) {
      return widget.itemBuilder.first(context, focusNodes.first);
    }

    buildContainer(int i, SplitViewItemBuilder builder) {
      return FocusableActionDetector(
        onShowFocusHighlight: (hasFocus) {
          if (hasFocus) {
            focusNodes[i].requestFocus();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: focusNodes[i].hasFocus
                  ? context.theme.colors.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: builder(context, focusNodes[i]),
        ),
      );
    }

    buildHandle(bool isHorizontal, void Function(double delta) onDrag) {
      return MouseRegion(
        cursor: isHorizontal
            ? SystemMouseCursors.resizeLeftRight
            : SystemMouseCursors.resizeUpDown,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (d) => onDrag(isHorizontal ? d.delta.dx : d.delta.dy),
        ),
      );
    }

    /// Lays out [left] and [right] side by side.
    /// The drag handle is overlaid at the boundary via a [Stack]+[Positioned].
    horizontalSplit(
      BoxConstraints constraints,
      Widget left,
      Widget right,
      double Function() ratioGetter,
      void Function(double) ratioSetter,
    ) {
      final usable = constraints.maxWidth - widget.spacing;
      final lw = ratioGetter() * usable;
      final rw = usable - lw;
      return Stack(
        children: [
          Row(
            children: [
              SizedBox(width: lw, child: left),
              SizedBox(width: widget.spacing),
              SizedBox(width: rw, child: right),
            ],
          ),
          Positioned(
            left: lw + widget.spacing / 2 - _kDividerExtent / 2,
            top: 0,
            width: _kDividerExtent,
            height: constraints.maxHeight,
            child: buildHandle(true, (dx) {
              ratioSetter((ratioGetter() + dx / usable).clamp(0, 1));
            }),
          ),
        ],
      );
    }

    /// Lays out [top] and [bottom] stacked.
    /// The drag handle is overlaid at the boundary via a [Stack]+[Positioned].
    verticalSplit(
      BoxConstraints constraints,
      Widget top,
      Widget bottom,
      double Function() ratioGetter,
      void Function(double) ratioSetter,
    ) {
      final usable = constraints.maxHeight - widget.spacing;
      final th = ratioGetter() * usable;
      final bh = usable - th;
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(height: th, child: top),
              SizedBox(height: widget.spacing),
              SizedBox(height: bh, child: bottom),
            ],
          ),
          Positioned(
            left: 0,
            top: th + widget.spacing / 2 - _kDividerExtent / 2,
            width: constraints.maxWidth,
            height: _kDividerExtent,
            child: buildHandle(false, (dy) {
              ratioSetter((ratioGetter() + dy / usable).clamp(0, 1));
            }),
          ),
        ],
      );
    }

    build2(BoxConstraints constraints) {
      if (widget.layout == .vertical) {
        return verticalSplit(
          constraints,
          buildContainer(0, widget.itemBuilder[0]),
          buildContainer(1, widget.itemBuilder[1]),
          () => ratio1.value,
          (v) => ratio1.value = v,
        );
      }
      return horizontalSplit(
        constraints,
        buildContainer(0, widget.itemBuilder[0]),
        buildContainer(1, widget.itemBuilder[1]),
        () => ratio1.value,
        (v) => ratio1.value = v,
      );
    }

    build3(BoxConstraints c) {
      switch (widget.layout) {
        case .horizontal:
          final usable = c.maxWidth - widget.spacing;
          final lw = ratio1.value * usable;
          final rw = usable - lw;
          return Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: lw,
                    child: buildContainer(0, widget.itemBuilder[0]),
                  ),
                  SizedBox(width: widget.spacing),
                  SizedBox(
                    width: rw,
                    child: verticalSplit(
                      BoxConstraints(maxWidth: rw, maxHeight: c.maxHeight),
                      buildContainer(1, widget.itemBuilder[1]),
                      buildContainer(2, widget.itemBuilder[2]),
                      () => ratio2.value,
                      (v) => ratio2.value = v,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: lw + widget.spacing / 2 - _kDividerExtent / 2,
                top: 0,
                width: _kDividerExtent,
                height: c.maxHeight,
                child: buildHandle(true, (dx) {
                  ratio1.value = (ratio1.value + dx / usable).clamp(0, 1);
                }),
              ),
            ],
          );

        case .vertical:
          final usable = c.maxHeight - widget.spacing;
          final th = ratio1.value * usable;
          final bh = usable - th;
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: th,
                    child: horizontalSplit(
                      BoxConstraints(maxWidth: c.maxWidth, maxHeight: th),
                      buildContainer(0, widget.itemBuilder[0]),
                      buildContainer(1, widget.itemBuilder[1]),
                      () => ratio2.value,
                      (v) => ratio2.value = v,
                    ),
                  ),
                  SizedBox(height: widget.spacing),
                  SizedBox(
                    height: bh,
                    child: buildContainer(2, widget.itemBuilder[2]),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: th + widget.spacing / 2 - _kDividerExtent / 2,
                width: c.maxWidth,
                height: _kDividerExtent,
                child: buildHandle(false, (dy) {
                  ratio1.value = (ratio1.value + dy / usable).clamp(0, 1);
                }),
              ),
            ],
          );

        case .topOneBottomTwo:
          final usable = c.maxHeight - widget.spacing;
          final th = ratio1.value * usable;
          final bh = usable - th;
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: th,
                    child: buildContainer(0, widget.itemBuilder[0]),
                  ),
                  SizedBox(height: widget.spacing),
                  SizedBox(
                    height: bh,
                    child: horizontalSplit(
                      BoxConstraints(maxWidth: c.maxWidth, maxHeight: bh),
                      buildContainer(1, widget.itemBuilder[1]),
                      buildContainer(2, widget.itemBuilder[2]),
                      () => ratio2.value,
                      (v) => ratio2.value = v,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: th + widget.spacing / 2 - _kDividerExtent / 2,
                width: c.maxWidth,
                height: _kDividerExtent,
                child: buildHandle(false, (dy) {
                  ratio1.value = (ratio1.value + dy / usable).clamp(0, 1);
                }),
              ),
            ],
          );

        case .leftTwoRightOne:
          final usable = c.maxWidth - widget.spacing;
          final lw = ratio1.value * usable;
          final rw = usable - lw;
          return Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: lw,
                    child: verticalSplit(
                      BoxConstraints(maxWidth: lw, maxHeight: c.maxHeight),
                      buildContainer(0, widget.itemBuilder[0]),
                      buildContainer(1, widget.itemBuilder[1]),
                      () => ratio2.value,
                      (v) => ratio2.value = v,
                    ),
                  ),
                  SizedBox(width: widget.spacing),
                  SizedBox(
                    width: rw,
                    child: buildContainer(2, widget.itemBuilder[2]),
                  ),
                ],
              ),
              Positioned(
                left: lw + widget.spacing / 2 - _kDividerExtent / 2,
                top: 0,
                width: _kDividerExtent,
                height: c.maxHeight,
                child: buildHandle(true, (dx) {
                  ratio1.value = (ratio1.value + dx / usable).clamp(0, 1);
                }),
              ),
            ],
          );
      }
    }

    build4(BoxConstraints c) {
      final usable = c.maxHeight - widget.spacing;
      final th = ratio1.value * usable;
      final bh = usable - th;
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: th,
                child: horizontalSplit(
                  BoxConstraints(maxWidth: c.maxWidth, maxHeight: th),
                  buildContainer(0, widget.itemBuilder[0]),
                  buildContainer(1, widget.itemBuilder[1]),
                  () => ratio2.value,
                  (v) => ratio2.value = v,
                ),
              ),
              SizedBox(height: widget.spacing),
              SizedBox(
                height: bh,
                child: horizontalSplit(
                  BoxConstraints(maxWidth: c.maxWidth, maxHeight: bh),
                  buildContainer(2, widget.itemBuilder[2]),
                  buildContainer(3, widget.itemBuilder[3]),
                  () => ratio3.value,
                  (v) => ratio3.value = v,
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            top: th + widget.spacing / 2 - _kDividerExtent / 2,
            width: c.maxWidth,
            height: _kDividerExtent,
            child: buildHandle(false, (dy) {
              ratio1.value = (ratio1.value + dy / usable).clamp(0, 1);
            }),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.all(widget.spacing),
      child: LayoutBuilder(
        builder: (_, constraints) {
          return switch (widget.itemBuilder.length) {
            2 => build2(constraints),
            3 => build3(constraints),
            _ => build4(constraints),
          };
        },
      ),
    );
  }
}
