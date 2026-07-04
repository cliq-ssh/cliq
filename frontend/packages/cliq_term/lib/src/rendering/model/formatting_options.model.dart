import 'package:flutter/material.dart';

enum Underline { none, single, double }

class FormattingOptions {
  static final FormattingOptions defaultFormat = FormattingOptions._internal();
  static final Map<int, FormattingOptions> _pool = {};

  late final Color? fgColor;
  late final Color? bgColor;
  late final bool bold;
  late final bool faint;
  late final bool italic;
  late final Underline underline;
  late final bool concealed;
  late final bool inverted;

  FormattingOptions._internal() {
    fgColor = null;
    bgColor = null;
    bold = false;
    faint = false;
    italic = false;
    underline = Underline.none;
    concealed = false;
    inverted = false;
  }

  FormattingOptions._raw({
    required this.fgColor,
    required this.bgColor,
    required this.bold,
    required this.faint,
    required this.italic,
    required this.underline,
    required this.concealed,
    required this.inverted,
  });

  factory FormattingOptions({
    Color? fgColor,
    Color? bgColor,
    bool bold = false,
    bool faint = false,
    bool italic = false,
    Underline underline = Underline.none,
    bool concealed = false,
    bool inverted = false,
  }) {
    final hash = Object.hash(
      fgColor,
      bgColor,
      bold,
      faint,
      italic,
      underline,
      concealed,
      inverted,
    );

    return _pool.putIfAbsent(
      hash,
      () => FormattingOptions._raw(
        fgColor: fgColor,
        bgColor: bgColor,
        bold: bold,
        faint: faint,
        italic: italic,
        underline: underline,
        concealed: concealed,
        inverted: inverted,
      ),
    );
  }

  Color? get effectiveFgColor =>
      inverted ? (bgColor ?? Colors.transparent) : (concealed ? null : fgColor);
  Color? get effectiveBgColor =>
      inverted ? (fgColor ?? Colors.transparent) : bgColor;

  static FormattingOptions clone(FormattingOptions other) {
    return FormattingOptions(
      fgColor: other.fgColor,
      bgColor: other.bgColor,
      bold: other.bold,
      faint: other.faint,
      italic: other.italic,
      underline: other.underline,
      concealed: other.concealed,
      inverted: other.inverted,
    );
  }

  FormattingOptions copyWith({
    Color? fgColor,
    Color? bgColor,
    bool? bold,
    bool? faint,
    bool? italic,
    Underline? underline,
    bool? concealed,
    bool? inverted,
  }) {
    return FormattingOptions(
      fgColor: fgColor ?? this.fgColor,
      bgColor: bgColor ?? this.bgColor,
      bold: bold ?? this.bold,
      faint: faint ?? this.faint,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      concealed: concealed ?? this.concealed,
      inverted: inverted ?? this.inverted,
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
        other.concealed == concealed &&
        other.inverted == inverted;
  }

  @override
  int get hashCode => Object.hash(
    fgColor,
    bgColor,
    bold,
    faint,
    italic,
    underline,
    concealed,
    inverted,
  );
}
