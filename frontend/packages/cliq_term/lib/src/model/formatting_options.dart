import 'package:flutter/material.dart';

enum Underline { none, single, double }

class FormattingOptions {
  late Color? fgColor;
  late Color? bgColor;
  late bool bold;
  late bool faint;
  late bool italic;
  late Underline underline;
  late bool concealed;

  FormattingOptions() {
    reset();
  }

  static FormattingOptions clone(FormattingOptions other) {
    final fmt = FormattingOptions();
    fmt.fgColor = other.fgColor;
    fmt.bgColor = other.bgColor;
    fmt.bold = other.bold;
    fmt.faint = other.faint;
    fmt.italic = other.italic;
    fmt.underline = other.underline;
    fmt.concealed = other.concealed;
    return fmt;
  }

  void reset() {
    fgColor = null;
    bgColor = null;
    bold = false;
    faint = false;
    italic = false;
    underline = Underline.none;
    concealed = false;
  }

  TextStyle toTextStyle({
    required Color defaultFg,
    required Color defaultBg,
    double? fontSize,
  }) {
    final effectiveFg = concealed
        ? defaultFg.withAlpha(0)
        : (fgColor ?? defaultFg);
    final effectiveBg = bgColor ?? defaultBg;

    return TextStyle(
      color: effectiveFg,
      backgroundColor: effectiveBg,
      fontSize: fontSize,
      fontFamily: 'monospace',
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: underline == Underline.none
          ? TextDecoration.none
          : TextDecoration.underline,
      decorationStyle: underline == Underline.double
          ? TextDecorationStyle.double
          : TextDecorationStyle.solid,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FormattingOptions &&
        other.fgColor == fgColor &&
        other.bgColor == bgColor &&
        other.bold == bold &&
        other.faint == faint &&
        other.italic == italic &&
        other.underline == underline &&
        other.concealed == concealed;
  }

  @override
  int get hashCode =>
      Object.hash(fgColor, bgColor, bold, faint, italic, underline, concealed);
}
