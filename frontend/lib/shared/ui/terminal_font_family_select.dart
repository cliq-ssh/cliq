import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';

/// Wrapper around [FSlider] for terminal font size selection
class TerminalFontFamilySelect extends StatelessWidget {
  static const List<String> fonts = ['JetBrainsMono', 'SourceCodePro'];

  final String selectedFontFamily;
  final ValueChanged<String>? onChange;

  const TerminalFontFamilySelect({
    super.key,
    required this.selectedFontFamily,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return FSelect<String>.rich(
      control: .managed(
        initial: selectedFontFamily,
        onChange: (value) {
          if (value != null) {
            onChange?.call(value);
          }
        },
      ),
      label: Text('Font Family'),
      hint: selectedFontFamily,
      format: (s) => s,
      children: [
        for (final font in fonts)
          FSelectItem(
            title: Text(
              font,
              style: TextStyle(fontFamily: font, fontWeight: .normal),
            ),
            value: font,
          ),
      ],
    );
  }
}
