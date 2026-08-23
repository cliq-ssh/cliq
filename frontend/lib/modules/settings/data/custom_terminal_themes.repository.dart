import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/repository.dart';

final class CustomTerminalThemesRepository
    extends Repository<CustomTerminalThemes, CustomTerminalTheme> {
  CustomTerminalThemesRepository(super.db);

  @override
  TableInfo<CustomTerminalThemes, CustomTerminalTheme> get table =>
      db.customTerminalThemes;
}
