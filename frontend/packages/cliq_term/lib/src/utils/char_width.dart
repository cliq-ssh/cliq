import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/cupertino.dart';

class CharWidth {
  static final Map<TerminalTypography, (double, double)> _measureCache = {};

  const CharWidth._();

  /// Calculates the width and height of a single character cell based on the provided typography.
  static (double width, double height) measureChar(
    TerminalTypography typography,
  ) {
    if (_measureCache.containsKey(typography)) {
      return _measureCache[typography]!;
    }
    final probe = TextPainter(
      text: TextSpan(text: 'MMMM', style: typography.toTextStyle()),
      textDirection: TextDirection.ltr,
    )..layout();
    final res = (probe.width / 4, probe.height);
    _measureCache[typography] = res;
    return res;
  }

  /// Whether [codepoint] is a Unicode Braille Pattern (U+2800-U+28FF).
  static bool isBraillePattern(int codepoint) => codepoint >= 0x2800 && codepoint <= 0x28FF;
}
