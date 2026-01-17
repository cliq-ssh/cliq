import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import 'database.dart';

abstract class Repository<T extends Table, R> {
  late final Logger _log = Logger('Repository[$R]');

  final CliqDatabase db;

  Repository(this.db);

  TableInfo<T, R> get table;

  Selectable<R> selectAll() => db.select(table);

  Future<int> insert(UpdateCompanion<R> row) {
    return db.into(table).insert(row).then((id) {
      _log.finest('Inserted row with id $id');
      return id;
    });
  }

  Future<List<int>> insertAll(List<UpdateCompanion<R>> rows) async {
    _log.finest('Inserting ${rows.length} rows');

    final List<int> ids = [];
    for (final row in rows) {
      ids.add(await insert(row));
    }
    return ids;
  }

  Future<void> insertAllBatch(List<UpdateCompanion<R>> rows) {
    _log.finest('Inserting ${rows.length} rows');
    return db.batch((batch) => batch.insertAll(table, rows));
  }

  Future<int> update(UpdateCompanion<R> row) {
    return db.update(table).write(row).then((count) {
      _log.finest('Updated $count rows');
      return count;
    });
  }

  Future<void> deleteById(int id) {
    _log.finest('Deleting row with id $id');
    return (db.delete(table)..where((row) => _whereId(row, id))).go();
  }

  Future<void> deleteAll() {
    _log.finest('Deleting all rows');
    return db.delete(table).go();
  }

  Future<int> count({Expression<bool> Function(T)? where}) async {
    _log.finest('Counting all rows');
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
