import 'package:flutter/cupertino.dart';

class TerminalScrollPhysics extends ClampingScrollPhysics {
  const TerminalScrollPhysics({super.parent});

  @override
  TerminalScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return .new(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // whether the current scroll position is out of the valid range
    final outOfRange =
        position.pixels < position.minScrollExtent ||
        position.pixels > position.maxScrollExtent;

    // likely a buffer swap or font size change, which can cause the scroll position to be out of range.
    // in this case, we want to correct the scroll position instantly without any animation
    if (velocity == 0 && outOfRange) {
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
