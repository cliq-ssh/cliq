class const TerminalTypography({
  required final String fontFamily,
  required final int fontSize,
}) {
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
  int get hashCode => Object.hash(fontFamily, fontSize);

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontSize': fontSize,
  };
}
