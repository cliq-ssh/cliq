import 'package:cliq/data/sqlite/database.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

abstract class Repository<T extends Table, R> {
  late final Logger _log = Logger('Repository[${table.actualTableName}]');

  final CliqDatabase db;

  Repository(this.db);

  TableInfo<T, R> get table;

  Future<List<R>> findAll() {
    _log.fine('Querying all rows');
    return db.select<T, R>(table).get();
  }

  Future<R?> findById(int id) {
    _log.fine('Querying row with id $id');
    return (db.select(
      table,
    )..where((row) => _whereId(row, id))).getSingleOrNull();
  }

  Future<List<R>> findAllByIds(List<int> ids) {
    _log.fine('Querying rows with ids $ids');
    return (db.select(table)..where((row) => _whereIds(row, ids))).get();
  }

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

  Expression<bool> _whereId(T row, int id) => _getIdColumn(row).equals(id);
  Expression<bool> _whereIds(T row, List<int> ids) =>
      _getIdColumn(row).isIn(ids);

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
