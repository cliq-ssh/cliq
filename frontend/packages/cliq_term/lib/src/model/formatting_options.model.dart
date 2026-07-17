import 'package:flutter/material.dart';

enum Underline { none, single, double }

class FormattingOptions {
  static final FormattingOptions defaultFormat = FormattingOptions._internal();
  static final Map<int, FormattingOptions> _pool = {};

  final Color? fgColor;
  final Color? bgColor;
  final String? hyperlink;
  final int _flags;

  static const int _boldMask = 1 << 0;
  static const int _faintMask = 1 << 1;
  static const int _italicMask = 1 << 2;
  static const int _concealedMask = 1 << 3;
  static const int _invertedMask = 1 << 4;
  static const int _underlineMask = 3 << 5;
  static const int _underlineShift = 5;

  FormattingOptions._internal()
    : fgColor = null,
      bgColor = null,
      hyperlink = null,
      _flags = 0;

  FormattingOptions._raw(
    this.fgColor,
    this.bgColor,
    this.hyperlink,
    this._flags,
  );

  factory FormattingOptions({
    Color? fgColor,
    Color? bgColor,
    String? hyperlink,
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

    final hash = Object.hash(fgColor, bgColor, hyperlink, flags);

    return _pool.putIfAbsent(
      hash,
      () => FormattingOptions._raw(fgColor, bgColor, hyperlink, flags),
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
      hyperlink: other.hyperlink,
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
      hyperlink: hyperlink, // preserved through normal SGR copyWith calls
      bold: bold ?? this.bold,
      faint: faint ?? this.faint,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      concealed: concealed ?? this.concealed,
      inverted: inverted ?? this.inverted,
    );
  }

  /// Separate from [copyWith] because the hyperlink needs to be explicitly
  /// clearable to null (closing a link), which the `??`-based copyWith
  /// pattern can't express.
  FormattingOptions copyWithHyperlink(String? hyperlink) {
    return FormattingOptions(
      fgColor: fgColor,
      bgColor: bgColor,
      hyperlink: hyperlink,
      bold: bold,
      faint: faint,
      italic: italic,
      underline: underline,
      concealed: concealed,
      inverted: inverted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormattingOptions &&
        other.fgColor == fgColor &&
        other.bgColor == bgColor &&
        other.hyperlink == hyperlink &&
        other._flags == _flags;
  }

  @override
  int get hashCode => Object.hash(fgColor, bgColor, hyperlink, _flags);
}
