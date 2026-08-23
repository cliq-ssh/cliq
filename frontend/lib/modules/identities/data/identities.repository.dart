import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class IdentitiesRepository extends Repository<Identities, Identity> {
  new(super.db);

  @override
  TableInfo<Identities, Identity> get table => db.identities;
}
