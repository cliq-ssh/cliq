import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class KeyRepository extends Repository<Keys, Key> {
  new(super.db);

  @override
  TableInfo<Keys, Key> get table => db.keys;
}
