import 'package:flutter/services.dart';

final class CliqColorScheme {
  final Brightness brightness;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final Color background;
  final Color onBackground;
  final Color onBackground70;
  final Color secondaryBackground;
  final Color onSecondaryBackground;
  final Color onSecondaryBackground70;
  final Color primary;
  final Color primary30;
  final Color onPrimary;
  final Color onPrimary50;
  final Color error;
  final Color error50;

  CliqColorScheme({
    required this.brightness,
    required this.systemUiOverlayStyle,
    required this.background,
    required this.onBackground,
    required this.secondaryBackground,
    required this.onSecondaryBackground,
    required this.primary,
    required this.onPrimary,
    required this.error,
  }) : onBackground70 = _blend(onBackground, background, .7),
       onSecondaryBackground70 = _blend(
         onSecondaryBackground,
         secondaryBackground,
         .7,
       ),
       primary30 = _blend(primary, background, .3),
       onPrimary50 = _blend(onPrimary, background, .5),
       error50 = _blend(error, secondaryBackground, .3);

  static Color _blend(Color fg, Color bg, double opacity) {
    return Color.alphaBlend(fg.withValues(alpha: opacity), bg);
  }
}
