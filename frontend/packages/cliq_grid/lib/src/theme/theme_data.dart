import '../../cliq_grid.dart';

final class CliqThemeData {
  final bool debug;

  final CliqBreakpoints breakpoints;
  final CliqGrid grid;

  final CliqGridColumnStyle gridColumnStyle;

  const CliqThemeData({
    required this.debug,
    required this.breakpoints,
    required this.grid,
    required this.gridColumnStyle,
  });

  factory CliqThemeData.inherit({
    CliqBreakpoints? breakpoints,
    CliqGrid? grid,
    bool debug = false,
  }) {
    return CliqThemeData(
      debug: debug,
      breakpoints: breakpoints ?? CliqBreakpoints(),
      grid: grid ?? const CliqGrid(),
      gridColumnStyle: CliqGridColumnStyle.inherit(debug: debug),
    );
  }
}
