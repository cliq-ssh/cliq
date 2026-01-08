import 'package:cliq/modules/settings/data/custom_terminal_themes_repository.dart';
import 'package:cliq/shared/data/database.dart';

final class CustomTerminalThemeService {
  final CustomTerminalThemesRepository customTerminalThemesRepository;

  const CustomTerminalThemeService(this.customTerminalThemesRepository);

  Stream<List<CustomTerminalTheme>> watchAll() {
    return customTerminalThemesRepository.selectAll().watch();
  }
}
