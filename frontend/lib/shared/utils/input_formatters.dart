import 'package:flutter/services.dart';

final class InputFormatters {
  const InputFormatters._();

  static List<TextInputFormatter> hex() {
    return [
      LengthLimitingTextInputFormatter(7),
      PrefixTextInputFormatter('#'),
      FilteringTextInputFormatter.allow(
        RegExp(r'^#?([0-9a-fA-F]{0,6})$'),
        replacementString: '#FFFFFF',
      ),
      CaseTextFormatter(),
    ];
  }
}

class CaseTextFormatter extends TextInputFormatter {
  final bool toUpperCase;
  const CaseTextFormatter({this.toUpperCase = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: toUpperCase
          ? newValue.text.toUpperCase()
          : newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class PrefixTextInputFormatter extends TextInputFormatter {
  final String prefix;
  const PrefixTextInputFormatter(this.prefix);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.startsWith(prefix)) {
      final newText = prefix + newValue.text;
      return TextEditingValue(
        text: newText,
        selection: .collapsed(offset: newText.length),
      );
    }
    return newValue;
  }
}
