import 'package:drift/drift.dart';

import '../database.dart';
import '../repository.dart';

final class IdentitiesRepository extends Repository<Identities, Identity> {
  IdentitiesRepository(super.db);

  @override
  TableInfo<Identities, Identity> get table => db.identities;
}
