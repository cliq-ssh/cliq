import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/services.dart';

extension CliqThemes on Never {
  static final standard = (
    light: CliqThemeData.inherit(
      //      debug: kDebugMode,
      colorScheme: CliqColorScheme(
        brightness: Brightness.light,
        systemUiOverlayStyle: SystemUiOverlayStyle.dark,
        background: Color(0xFFFFFFFF),
        onBackground: Color(0xFF000000),
        secondaryBackground: Color(0xFFCBCBCB),
        onSecondaryBackground: Color(0xFF000000),
        primary: Color(0xFF007AFF),
        onPrimary: Color(0xFFFFFFFF),
        error: Color(0xFFFF0000),
      ),
    ),
    dark: CliqThemeData.inherit(
      //      debug: kDebugMode,
      colorScheme: CliqColorScheme(
        brightness: Brightness.dark,
        systemUiOverlayStyle: SystemUiOverlayStyle.light,
        background: Color(0xFF00001d),
        onBackground: Color(0xFFFFFFFF),
        secondaryBackground: Color(0xFF252529),
        onSecondaryBackground: Color(0xFFFFFFFF),
        primary: Color(0xFF007AFF),
        onPrimary: Color(0xFFFFFFFF),
        error: Color(0xFFFF0000),
      ),
    ),
  );
}
