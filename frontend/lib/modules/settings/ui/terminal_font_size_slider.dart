import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';

/// Wrapper around [FSlider] for terminal font size selection
class TerminalFontSizeSlider extends StatelessWidget {
  final int selectedFontSize;
  final Function(int)? onEnd;

  const TerminalFontSizeSlider({
    super.key,
    required this.selectedFontSize,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return FSlider(
      control: .managedContinuous(
        initial: FSliderValue(min: 0, max: (selectedFontSize - 4) / 48),
      ),
      label: Text('Font Size'),
      tooltipBuilder: (_, value) => Text('${(value * 48).round() + 4}'),
      onEnd: (value) => onEnd?.call((value.max * 48).round() + 4),
      marks: [
        for (var i = 0; i <= 12; i++)
          FSliderMark(
            value: i / 12,
            label: ((i * 4) + 4) % 8 != 0 ? Text('${(i * 4) + 4}') : null,
            tick: ((i * 4) + 4) % 8 == 0,
          ),
      ],
    );
  }
}
