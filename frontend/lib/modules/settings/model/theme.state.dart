import 'package:cliq/modules/settings/model/theme.model.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../data/store.dart';

class ThemeState {
  final CliqTheme activeTheme;
  final ThemeMode themeMode;

  const ThemeState({required this.activeTheme, required this.themeMode});

  ThemeState.initial()
    : activeTheme = StoreKey.theme.readSync() ?? CliqTheme.zinc,
      themeMode = StoreKey.themeMode.readSync() ?? ThemeMode.system;

  FThemeData get activeThemeWithMode => activeTheme.getThemeWithMode(themeMode);

  ThemeState copyWith({CliqTheme? activeTheme, ThemeMode? themeMode}) {
    return ThemeState(
      activeTheme: activeTheme ?? this.activeTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
