final class CliqGrid {
  final int cols;
  final int gutterSize;

  const CliqGrid({this.cols = 12, this.gutterSize = 24});

  double get oneColumnRatio => 1.0 / cols;
}
