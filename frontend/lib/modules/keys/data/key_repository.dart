import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/repository.dart';

final class KeyRepository extends Repository<Keys, Key> {
  KeyRepository(super.db);

  @override
  TableInfo<Keys, Key> get table => db.keys;
}
