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
    return switch (this) {
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

  String getBannerPath(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'assets/logo/schkeip-banner_light.png',
      ThemeMode.dark => 'assets/logo/schkeip-banner_dark.png',
      ThemeMode.system =>
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light
            ? 'assets/logo/schkeip-banner_light.png'
            : 'assets/logo/schkeip-banner_dark.png',
    };
  }
}
