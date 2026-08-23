import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';
import '../../../shared/data/repository.dart';

final class IdentitiesRepository extends Repository<Identities, Identity> {
  IdentitiesRepository(super.db);

  @override
  TableInfo<Identities, Identity> get table => db.identities;
}
