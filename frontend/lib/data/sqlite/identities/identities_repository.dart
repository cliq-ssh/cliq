import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/data/sqlite/repository.dart';
import 'package:drift/drift.dart';

final class IdentitiesRepository extends Repository<Identities, Identity> {
  IdentitiesRepository(super.db);

  @override
  TableInfo<Identities, Identity> get table => db.identities;
}
