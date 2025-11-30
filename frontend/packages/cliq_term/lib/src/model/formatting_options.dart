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
