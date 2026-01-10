import 'package:cliq/shared/data/store.dart';

import '../../../shared/data/database.dart';
import '../../../shared/provider/abstract_entity.state.dart';
import '../provider/terminal_theme.provider.dart';

class CustomTerminalThemeState
    extends AbstractEntityState<CustomTerminalTheme, CustomTerminalThemeState> {
  final int activeDefaultThemeId;

  const CustomTerminalThemeState({
    required this.activeDefaultThemeId,
    super.entities = const [],
  });

  CustomTerminalThemeState.initial()
    : activeDefaultThemeId = StoreKey.defaultTerminalThemeId.readSync()!,
      super.initial();

  CustomTerminalTheme get effectiveActiveDefaultTheme =>
      entities.where((t) => t.id == activeDefaultThemeId).firstOrNull ??
      defaultTerminalColorTheme;

  CustomTerminalThemeState copyWith({
    int? activeDefaultThemeId,
    List<CustomTerminalTheme>? entities,
  }) {
    return CustomTerminalThemeState(
      activeDefaultThemeId: activeDefaultThemeId ?? this.activeDefaultThemeId,
      entities: entities ?? this.entities,
    );
  }
}
