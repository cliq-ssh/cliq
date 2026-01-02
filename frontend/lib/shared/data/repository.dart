import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import 'database.dart';

abstract class Repository<T extends Table, R> {
  late final Logger _log = Logger('Repository[${table.actualTableName}]');

  final CliqDatabase db;

  Repository(this.db);

  TableInfo<T, R> get table;

  Future<int> insert(UpdateCompanion<R> row) {
    _log.fine('Inserting row: $row');
    return db.into(table).insert(row);
  }

  Future<void> insertAll(List<UpdateCompanion<R>> rows) {
    _log.fine('Inserting ${rows.length} rows: ${rows.join(', ')}');
    return db.batch((batch) => batch.insertAll(table, rows));
  }

  Future<int> update(UpdateCompanion<R> row) {
    _log.fine('Updating row: $row');
    return db.update(table).write(row);
  }

  Future<void> deleteById(int id) {
    _log.fine('Deleting row with id $id');
    return (db.delete(table)..where((row) => _whereId(row, id))).go();
  }

  Future<void> deleteAll() {
    _log.fine('Deleting all rows');
    return db.delete(table).go();
  }

  Future<int> count({Expression<bool> Function(T)? where}) async {
    _log.fine('Counting all rows');
    return await table.count(where: where).getSingle();
  }

  Expression<bool> _whereId(T row, int id) => _getIdColumn(row).equals(id);
  GeneratedColumn<Object> _getIdColumn(T row) {
    final idColumn = table.columnsByName['id'];

    if (idColumn == null) {
      throw ArgumentError.value(
        this,
        'this',
        'Must be a table with an id column',
      );
    }

    if (idColumn.type != DriftSqlType.int) {
      throw ArgumentError('Column `id` is not an integer');
    }

    return idColumn;
  }
}
