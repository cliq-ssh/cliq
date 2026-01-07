import 'package:cliq_term/cliq_term.dart';

import '../../../shared/data/store.dart';

class TerminalColorsState {
  final Map<String, TerminalColorTheme> themes;
  final String activeTheme;

  const TerminalColorsState({required this.themes, required this.activeTheme});

  TerminalColorsState.initial()
    : typography = StoreKey.terminalTypography.readSync()!;

  TerminalColorsState copyWith({Map<String, TerminalColorTheme>? themes, String? activeTheme}) {
    return TerminalColorsState(
      themes: themes ?? this.themes,
      activeTheme: activeTheme ?? this.activeTheme,
    );
  }
