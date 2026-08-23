import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/abstract_entity.state.dart';

class CustomTerminalThemeState
    extends AbstractEntityState<CustomTerminalTheme, CustomTerminalThemeState> {
  const new({super.entities = const []});

  new initial() : super.initial();

  CustomTerminalTheme? findById(DbId id, {bool isDefaultTheme = false}) {
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
