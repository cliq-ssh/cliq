import 'package:cliq/modules/settings/data/logs.repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

final class const LogService(final LogsRepository _logsRepository) {
  Stream<List<Log>> watchAll() {
    return _logsRepository.db.select(_logsRepository.table).watch();
  }

  Future<int> create({
    required int logLevel,
    required String loggerName,
    required String message,
    required DateTime createdAt,
  }) async {
    return (await _logsRepository.insert(
      LogsCompanion(
        logLevel: Value(logLevel),
        loggerName: Value(loggerName),
        message: Value(message),
        createdAt: Value(createdAt),
      ),
    )).id;
  }

  Future<void> deleteById(DbId id) => _logsRepository.deleteById(id);
}
