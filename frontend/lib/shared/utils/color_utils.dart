import 'dart:math';
import 'dart:ui';

class const ColorUtils._() {
  /// Calculates the contrast ratio between two colors.
  static double contrastRatio(Color foreground, Color background) {
    final darker = foreground.computeLuminance();
    final lighter = background.computeLuminance();
    return (max(darker, lighter) + 0.05) / (min(darker, lighter) + 0.05);
  }
}
