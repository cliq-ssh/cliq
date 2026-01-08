import 'package:cliq/shared/data/database.dart';
import 'package:riverpod/riverpod.dart';

import '../../../shared/provider/abstract_entity.notifier.dart';
import '../../../shared/provider/abstract_entity.state.dart';

final terminalThemeProvider = NotifierProvider(CustomTerminalThemeNotifier.new);

typedef CustomTerminalThemeEntityState =
    AbstractEntityState<CustomTerminalTheme>;

class CustomTerminalThemeNotifier
    extends
        AbstractEntityNotifier<
          CustomTerminalTheme,
          CustomTerminalThemeEntityState
        > {
  // TODO: import
  @override
  CustomTerminalThemeEntityState buildInitialState() => .initial();
  @override
  Stream<List<CustomTerminalTheme>> get entityStream =>
      CliqDatabase.customTerminalThemeService.watchAll();
}
