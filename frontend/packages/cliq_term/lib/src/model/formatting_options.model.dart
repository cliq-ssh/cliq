import 'package:flutter/material.dart';

enum Underline { none, single, double }

class FormattingOptions {
  static final FormattingOptions defaultFormat = FormattingOptions._internal();
  static final Map<int, FormattingOptions> _pool = {};

  final Color? fgColor;
  final Color? bgColor;
  final int _flags;

  static const int _boldMask = 1 << 0;
  static const int _faintMask = 1 << 1;
  static const int _italicMask = 1 << 2;
  static const int _concealedMask = 1 << 3;
  static const int _invertedMask = 1 << 4;
  static const int _underlineMask = 3 << 5;
  static const int _underlineShift = 5;

  FormattingOptions._internal() : fgColor = null, bgColor = null, _flags = 0;

  FormattingOptions._raw(this.fgColor, this.bgColor, this._flags);

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
    int flags = 0;
    if (bold) flags |= _boldMask;
    if (faint) flags |= _faintMask;
    if (italic) flags |= _italicMask;
    if (concealed) flags |= _concealedMask;
    if (inverted) flags |= _invertedMask;
    flags |= (underline.index << _underlineShift) & _underlineMask;

    final hash = Object.hash(fgColor, bgColor, flags);

    return _pool.putIfAbsent(
      hash,
      () => FormattingOptions._raw(fgColor, bgColor, flags),
    );
  }

  bool get bold => (_flags & _boldMask) != 0;
  bool get faint => (_flags & _faintMask) != 0;
  bool get italic => (_flags & _italicMask) != 0;
  bool get concealed => (_flags & _concealedMask) != 0;
  bool get inverted => (_flags & _invertedMask) != 0;
  Underline get underline =>
      Underline.values[(_flags & _underlineMask) >> _underlineShift];

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
        other._flags == _flags;
  }

  @override
  int get hashCode => Object.hash(fgColor, bgColor, _flags);
}
