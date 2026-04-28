import 'package:flutter/cupertino.dart';

class TerminalTypography {
  final String fontFamily;
  final int fontSize;

  const TerminalTypography({required this.fontFamily, required this.fontSize});

  static TerminalTypography? fromJson(Map<String, dynamic>? json) {
    if (json == null ||
        json['fontFamily'] == null ||
        json['fontSize'] == null) {
      return null;
    }
    return TerminalTypography(
      fontFamily: json['fontFamily'] as String,
      fontSize: json['fontSize'] as int,
    );
  }

  TextStyle toTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize.toDouble(),
      fontWeight: .w500,
      fontVariations: [
        // TODO: figure out a way to use the normal font weight
        // TODO: see https://docs.flutter.dev/release/breaking-changes/font-weight-variation
        FontVariation('wght', 500),
      ],
    );
  }

  @override
  String toString() =>
      'TerminalTypography(fontFamily: $fontFamily, fontSize: $fontSize)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TerminalTypography &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode => fontFamily.hashCode ^ fontSize.hashCode;

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontSize': fontSize,
  };
}
