import 'package:cliq/modules/settings/model/terminal_typography.state.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:riverpod/riverpod.dart';

import '../../../shared/data/store.dart';

final NotifierProvider<TerminalTypographyNotifier, TerminalTypographyState>
terminalTypographyProvider = NotifierProvider(TerminalTypographyNotifier.new);

class TerminalTypographyNotifier extends Notifier<TerminalTypographyState> {
  void setTypography(TerminalTypography typography) {
    StoreKey.terminalTypography.write(typography);
    state = state.copyWith(typography: typography);
  }

  @override
  TerminalTypographyState build() => TerminalTypographyState.initial();
}
