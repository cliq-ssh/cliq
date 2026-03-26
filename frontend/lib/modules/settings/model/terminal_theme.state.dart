import 'package:cliq/shared/data/store.dart';

import '../../../shared/data/database.dart';
import '../../../shared/provider/abstract_entity.state.dart';
import '../provider/terminal_theme.provider.dart';

class CustomTerminalThemeState
    extends AbstractEntityState<CustomTerminalTheme, CustomTerminalThemeState> {
  const CustomTerminalThemeState({super.entities = const []});

  CustomTerminalThemeState.initial() : super.initial();

  CustomTerminalTheme? findById(int id, {bool isDefaultTheme = false}) {
    if (id == defaultTerminalColorTheme.id) {
      return defaultTerminalColorTheme;
    }

    for (final entity in entities) {
      if (entity.id == id) {
        return entity;
      }
    }

    // if not found AND this is searching for the user specified default theme, reset the default theme in store
    // (since it doesnt seem to be valid)
    if (isDefaultTheme) {
      StoreKey.defaultTerminalThemeId.delete();
    }

    // return built-in theme as fallback
    return defaultTerminalColorTheme;
  }

  CustomTerminalThemeState copyWith({List<CustomTerminalTheme>? entities}) {
    return CustomTerminalThemeState(entities: entities ?? this.entities);
  }
}
