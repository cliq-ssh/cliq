import '../../../shared/data/database.dart';
import '../../../shared/provider/abstract_entity.state.dart';
import '../provider/terminal_theme.provider.dart';

class CustomTerminalThemeState
    extends AbstractEntityState<CustomTerminalTheme, CustomTerminalThemeState> {
  final CustomTerminalTheme? activeDefaultTheme;

  const CustomTerminalThemeState({
    required this.activeDefaultTheme,
    super.entities = const [],
  });

  CustomTerminalThemeState.initial()
    : activeDefaultTheme = null,
      super.initial();

  CustomTerminalTheme get effectiveActiveDefaultTheme =>
      activeDefaultTheme ?? defaultTerminalColorTheme;

  CustomTerminalThemeState copyWith({
    CustomTerminalTheme? activeDefaultTheme,
    List<CustomTerminalTheme>? entities,
  }) {
    return CustomTerminalThemeState(
      activeDefaultTheme: activeDefaultTheme ?? this.activeDefaultTheme,
      entities: entities ?? this.entities,
    );
  }
}
