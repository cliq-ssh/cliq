import 'package:cliq/shared/data/database.dart';
import 'package:flterm/flterm.dart';

extension CustomTerminalThemeExtension on CustomTerminalTheme {
  TerminalTheme toTerminalTheme() {
    return .new(palette: toColorPalette(), selection: toSelectionTheme());
  }

  ColorPalette toColorPalette() {
    return .new(
      background: background,
      foreground: foreground,
      ansiColors: [
        black,
        red,
        green,
        yellow,
        blue,
        purple,
        cyan,
        white,
        brightBlack,
        brightRed,
        brightGreen,
        brightYellow,
        brightBlue,
        brightPurple,
        brightCyan,
        brightWhite,
      ],
    );
  }

  SelectionTheme toSelectionTheme() {
    return .new(
      foreground: .fixed(selectionForeground),
      background: .fixed(selectionBackground),
    );
  }
}
