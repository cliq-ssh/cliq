import 'package:cliq_term/cliq_term.dart';

import '../../../shared/data/database.dart';

extension CustomTerminalThemeExtension on CustomTerminalTheme {
  TerminalTheme toTerminalTheme() {
    return TerminalTheme(
      cursorColor: cursorColor,
      selectionColor: selectionBackgroundColor,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      black: blackColor,
      red: redColor,
      green: greenColor,
      yellow: yellowColor,
      blue: blueColor,
      purple: purpleColor,
      cyan: cyanColor,
      white: whiteColor,
      brightBlack: brightBlackColor,
      brightRed: brightRedColor,
      brightGreen: brightGreenColor,
      brightYellow: brightYellowColor,
      brightBlue: brightBlueColor,
      brightPurple: brightPurpleColor,
      brightCyan: brightCyanColor,
      brightWhite: brightWhiteColor,
    );
  }
}
