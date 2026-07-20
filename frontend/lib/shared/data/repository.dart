import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

Uuid _uuid = const Uuid();

abstract class Repository<T extends Table, R> {
  late final Logger _log = Logger('Repository[$R]');

  final CliqDatabase db;

  Repository(this.db);

  TableInfo<T, R> get table;

  Selectable<R> selectAll() => db.select(table);

  Future<R> insert(UpdateCompanion<R> row) {
    final idColumn = table.columnsByName['id'];
    final columns = row.toColumns(false);

    final Insertable<R> toInsert =
        idColumn?.type == DriftSqlType.string && !columns.containsKey('id')
        ? RawValuesInsertable<R>({
            ...columns,
            'id': Variable<String>(_uuid.v4()),
          })
        : row;

    return db.into(table).insertReturning(toInsert).then((inserted) {
      _log.finest('Inserted row: $inserted');
      return inserted;
    });
  }

  Future<List<R>> insertAll(List<UpdateCompanion<R>> rows) async {
    _log.finest('Inserting ${rows.length} rows');

    final List<R> inserted = [];
    for (final row in rows) {
      inserted.add(await insert(row));
    }
    return inserted;
  }

  Future<void> insertAllBatch(
    List<UpdateCompanion<R>> rows, {
    InsertMode mode = .insertOrAbort,
  }) {
    _log.finest('Inserting ${rows.length} rows');
    final idColumn = table.columnsByName['id'];

    final toInsert = rows.map((row) {
      final columns = row.toColumns(false);
      if (idColumn?.type == DriftSqlType.string && !columns.containsKey('id')) {
        return RawValuesInsertable<R>({
          ...columns,
          'id': Variable<String>(_uuid.v4()),
        });
      }
      return row;
    }).toList();

    return db.batch((batch) => batch.insertAll(table, toInsert, mode: mode));
  }

  Future<int> updateById(DbId id, UpdateCompanion<R> row) {
    return (db.update(table)..where((t) => _whereId(t, id))).write(row).then((
      count,
    ) {
      _log.finest('Updated $count rows');
      return count;
    });
  }

  Future<void> deleteById(DbId id) {
    _log.finest('Deleting row with id $id');
    return (db.delete(table)..where((row) => _whereId(row, id))).go();
  }

  Future<void> deleteByIds(List<DbId> ids) async {
    _log.finest('Deleting rows with ids $ids');
    return db.batch((batch) {
      for (final id in ids) {
        batch.deleteWhere(table, (row) => _whereId(row, id));
      }
    });
  }

  Future<void> deleteAll() {
    _log.finest('Deleting all rows');
    return db.delete(table).go();
  }

  Future<int> count({Expression<bool> Function(T)? where}) async {
    _log.finest('Counting all rows');
    return await table.count(where: where).getSingle();
  }

  Expression<bool> _whereId(T row, DbId id) => _getIdColumn(row).equals(id);

  GeneratedColumn<Object> _getIdColumn(T row) {
    final idColumn = table.columnsByName['id'];

    if (idColumn == null) {
      throw ArgumentError.value(
        this,
        'this',
        'Must be a table with an id column',
      );
    }

    if (idColumn.type != DriftSqlType.string) {
      throw ArgumentError('Column `id` is not a string');
    }

    return idColumn;
  }
}
