import 'package:cliq/modules/settings/data/custom_terminal_themes_repository.dart';
import 'package:cliq/shared/data/database.dart';

final class CustomTerminalThemeService {
  final CustomTerminalThemesRepository _customTerminalThemesRepository;

  const CustomTerminalThemeService(this._customTerminalThemesRepository);

  Stream<List<CustomTerminalTheme>> watchAll() {
    return _customTerminalThemesRepository.selectAll().watch();
  }

  Future<int> createCustomTerminalTheme(
    CustomTerminalThemesCompanion insert,
  ) async {
    return await _customTerminalThemesRepository.insert(insert);
  }
}
