import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../../../data/store.dart';
import '../model/theme.model.dart';
import '../model/theme.state.dart';

final NotifierProvider<ThemeNotifier, ThemeState> themeProvider =
    NotifierProvider(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeState> {
  void setTheme(CliqTheme theme) {
    StoreKey.theme.write(theme);
    state = state.copyWith(activeTheme: theme);
  }

  void setThemeMode(ThemeMode mode) {
    StoreKey.themeMode.write(mode);
    state = state.copyWith(themeMode: mode);
  }

  @override
  ThemeState build() => ThemeState.initial();
}
