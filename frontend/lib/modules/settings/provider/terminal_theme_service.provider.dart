import 'package:cliq/modules/settings/data/custom_terminal_theme_service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<CustomTerminalThemeService> terminalThemeServiceProvider =
    Provider(
      (ref) => CustomTerminalThemeService(
        ref.read(databaseProvider).customTerminalThemesRepository,
      ),
    );
