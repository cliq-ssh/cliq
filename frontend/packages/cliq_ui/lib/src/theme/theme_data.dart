import 'package:cliq_ui/cliq_ui.dart';
import 'package:cliq_ui/src/widgets/progress_bar.dart';

final class CliqThemeData {
  final bool debug;

  final CliqBreakpoints breakpoints;
  final CliqGrid grid;
  final CliqColorScheme colorScheme;
  final CliqTypographyData typography;
  final CliqStyle style;

  final CliqBottomNavigationBarStyle bottomNavigationBarStyle;
  final CliqTextFieldStyle textFieldStyle;
  final CliqGridColumnStyle gridColumnStyle;
  final CliqAppBarStyle appBarStyle;
  final CliqBlurContainerStyle blurContainerStyle;
  final CliqButtonStyle buttonStyle;
  final CliqCardStyle cardStyle;
  final CliqIconButtonStyle iconButtonStyle;
  final CliqScaffoldStyle scaffoldStyle;
  final CliqProgressBarStyle progressBarStyle;

  const CliqThemeData({
    required this.debug,
    required this.breakpoints,
    required this.grid,
    required this.colorScheme,
    required this.typography,
    required this.style,
    required this.bottomNavigationBarStyle,
    required this.textFieldStyle,
    required this.gridColumnStyle,
    required this.appBarStyle,
    required this.blurContainerStyle,
    required this.buttonStyle,
    required this.cardStyle,
    required this.iconButtonStyle,
    required this.scaffoldStyle,
    required this.progressBarStyle,
  });

  factory CliqThemeData.inherit({
    required CliqColorScheme colorScheme,
    CliqBreakpoints? breakpoints,
    CliqGrid? grid,
    CliqTypographyData? typography,
    CliqStyle? style,
    bool debug = false,
  }) {
    typography ??= CliqTypographyData.inherit(colorScheme: colorScheme);
    style ??= CliqStyle.inherit(
      colorScheme: colorScheme,
      typography: typography,
    );
    return CliqThemeData(
      debug: debug,
      breakpoints: breakpoints ?? CliqBreakpoints(),
      grid: grid ?? const CliqGrid(),
      colorScheme: colorScheme,
      typography: typography,
      style: style,
      bottomNavigationBarStyle: CliqBottomNavigationBarStyle.inherit(
        colorScheme: colorScheme,
      ),
      textFieldStyle: CliqTextFieldStyle.inherit(
        style: style,
        colorScheme: colorScheme,
      ),
      gridColumnStyle: CliqGridColumnStyle.inherit(debug: debug),
      appBarStyle: CliqAppBarStyle.inherit(
        style: style,
        colorScheme: colorScheme,
      ),
      blurContainerStyle: CliqBlurContainerStyle.inherit(
        style: style,
        colorScheme: colorScheme,
      ),
      buttonStyle: CliqButtonStyle.inherit(
        style: style,
        colorScheme: colorScheme,
      ),
      cardStyle: CliqCardStyle.inherit(style: style, colorScheme: colorScheme),
      iconButtonStyle: CliqIconButtonStyle.inherit(
        style: style,
        colorScheme: colorScheme,
      ),
      scaffoldStyle: CliqScaffoldStyle.inherit(colorScheme: colorScheme),
      progressBarStyle: CliqProgressBarStyle.inherit(
        style: style,
        colorScheme: colorScheme,
      ),
    );
  }
}
