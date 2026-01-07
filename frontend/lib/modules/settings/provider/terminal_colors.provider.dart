import 'package:cliq/modules/settings/model/terminal_colors.state.dart';
import 'package:riverpod/riverpod.dart';

final NotifierProvider<TerminalColorsNotifier, TerminalColorsState>
terminalColorsProvider = NotifierProvider(TerminalColorsNotifier.new);

class TerminalColorsNotifier extends Notifier<TerminalColorsState> {
  // TODO: load themes from files

  // TODO: import
  @override
  TerminalColorsState build() => TerminalColorsState.initial();
}
