import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

final class CliqColorScheme {
  final Brightness brightness;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final Color background;
  final Color onBackground;
  final Color onBackground20;
  final Color onBackground70;
  final Color secondaryBackground;
  final Color secondaryBackground50;
  final Color onSecondaryBackground;
  final Color onSecondaryBackground10;
  final Color onSecondaryBackground70;
  final Color primary;
  final Color primary30;
  final Color onPrimary;
  final Color onPrimary30;
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
  }) : onBackground20 = blend(onBackground, background, .2),
       onBackground70 = blend(onBackground, background, .7),
       secondaryBackground50 = blend(secondaryBackground, background, .5),
       onSecondaryBackground10 = blend(
         onSecondaryBackground,
         secondaryBackground,
         .1,
       ),
       onSecondaryBackground70 = blend(
         onSecondaryBackground,
         secondaryBackground,
         .7,
       ),
       primary30 = blend(primary, background, .3),
       onPrimary30 = blend(onPrimary, primary, .3),
       onPrimary50 = blend(onPrimary, primary, .5),
       error50 = blend(error, background, .5);

  static Color calculateOutlineColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness(
          hsl.lightness < 0.5
              ? (hsl.lightness + (1 - hsl.lightness) * 0.1)
              : (hsl.lightness * 0.8),
        )
        .toColor();
  }

  static Color blend(Color color, Color on, double opacity) {
    return Color.alphaBlend(color.withValues(alpha: opacity), on);
  }
}
