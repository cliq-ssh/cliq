import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forui/forui.dart';

enum CliqTheme {
  zinc,
  slate,
  red,
  rose,
  orange,
  green,
  blue,
  yellow,
  violet;

  ({FThemeData dark, FThemeData light}) get themeData {
    final themeData = switch (this) {
      CliqTheme.zinc => FThemes.zinc,
      CliqTheme.slate => FThemes.slate,
      CliqTheme.red => FThemes.red,
      CliqTheme.rose => FThemes.rose,
      CliqTheme.orange => FThemes.orange,
      CliqTheme.green => FThemes.green,
      CliqTheme.blue => FThemes.blue,
      CliqTheme.yellow => FThemes.yellow,
      CliqTheme.violet => FThemes.violet,
    };
    return Platform.isIOS || Platform.isAndroid
        ? (dark: themeData.dark.touch, light: themeData.light.touch)
        : (dark: themeData.dark.desktop, light: themeData.light.desktop);
  }

  FThemeData getThemeWithMode(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      return themeData.light;
    }
    if (mode == ThemeMode.dark) {
      return themeData.dark;
    }
    return getThemeWithBrightness(
      SchedulerBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  FThemeData getThemeWithBrightness(Brightness brightness) {
    return brightness == Brightness.light ? themeData.light : themeData.dark;
  }

  String getDisplayName() => 'appearance_color_theme_color.$name'.tr();
}
