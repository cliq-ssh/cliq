import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class CustomTerminalThemesRepository
    extends Repository<CustomTerminalThemes, CustomTerminalTheme> {
  new(super.db);

  @override
  TableInfo<CustomTerminalThemes, CustomTerminalTheme> get table =>
      db.customTerminalThemes;
}
