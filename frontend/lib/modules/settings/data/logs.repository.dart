import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class LogsRepository(super.db) extends Repository<Logs, Log> {
  @override
  TableInfo<Logs, Log> get table => db.logs;
}
