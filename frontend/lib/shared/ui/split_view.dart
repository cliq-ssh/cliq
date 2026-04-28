import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SplitViewHAlign { left, right }

enum SplitViewVAlign { top, bottom }

class SplitView extends StatefulHookConsumerWidget {
  final List<Widget> children;
  final List<(SplitViewVAlign, SplitViewHAlign)> alignments;

  const SplitView({
    super.key,
    required this.children,
    this.alignments = const [
      (.top, .left),
      (.top, .right),
      (.bottom, .left),
      (.bottom, .right),
    ],
  }) : assert(
         children.length > 0 && children.length <= 4,
         'SplitView supports only 1 to 4 children',
       );

  @override
  ConsumerState<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends ConsumerState<SplitView> {
  @override
  Widget build(BuildContext context) {
    final currentFocusIndex = useState(0);

    if (widget.children.length == 1) {
      return widget.children.first;
    }

    const spacing = 4.0;
    buildContainer(int i, Widget child) {
      return FocusableActionDetector(
        onShowFocusHighlight: (hasFocus) {
          if (hasFocus) currentFocusIndex.value = i;
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: currentFocusIndex.value == i
                  ? context.theme.colors.primary
                  : Colors.transparent,
              width: 1,
            )
          ),
          child: child,
        ),
      );
    }

    return Padding(
      padding: const .all(spacing + 1),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              for (var i = 0; i < widget.children.length; i++)
                Positioned(
                  left: widget.alignments[i].$2 == SplitViewHAlign.left
                      ? 0
                      : width / 2 + spacing / 2,
                  top: widget.alignments[i].$1 == SplitViewVAlign.top
                      ? 0
                      : height / 2 + spacing / 2,
                  width: width / 2 - spacing / 2,
                  height: height / 2 - spacing / 2,
                  child: buildContainer(i, widget.children[i]),
                ),
            ],
          );
        },
      ),
    );
  }
}
