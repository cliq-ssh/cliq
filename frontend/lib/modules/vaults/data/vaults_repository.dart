import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/repository.dart';

final class VaultsRepository extends Repository<Vaults, Vault> {
  VaultsRepository(super.db);

  @override
  TableInfo<Vaults, Vault> get table => db.vaults;
}
