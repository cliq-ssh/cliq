import '../../../shared/data/database.dart';
import '../../../shared/provider/abstract_entity.state.dart';
import '../provider/terminal_theme.provider.dart';

class CustomTerminalThemeState
    extends AbstractEntityState<CustomTerminalTheme, CustomTerminalThemeState> {
  const CustomTerminalThemeState({super.entities = const []});

  CustomTerminalThemeState.initial() : super.initial();

  CustomTerminalTheme? findById(int id) {
    if (id == defaultTerminalColorTheme.id) {
      return defaultTerminalColorTheme;
    }
    return entities.firstWhere((theme) => theme.id == id);
  }

  CustomTerminalThemeState copyWith({List<CustomTerminalTheme>? entities}) {
    return CustomTerminalThemeState(entities: entities ?? this.entities);
  }
}
