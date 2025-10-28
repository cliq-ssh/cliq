import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/data/sqlite/repository.dart';
import 'package:drift/drift.dart';

final class KeysRepository extends Repository<Keys, Key> {
  KeysRepository(super.db);

  @override
  TableInfo<Keys, Key> get table => db.keys;
}
