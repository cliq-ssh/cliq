import 'package:cliq_term/cliq_term.dart';

import '../../../shared/data/store.dart';

class TerminalTypographyState {
  final TerminalTypography typography;

  const TerminalTypographyState({required this.typography});

  TerminalTypographyState.initial()
    : typography = StoreKey.terminalTypography.readSync()!;

  TerminalTypographyState copyWith({TerminalTypography? typography}) {
    return TerminalTypographyState(typography: typography ?? this.typography);
  }
}
