import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/repository.dart';
import 'package:drift/drift.dart';

final class VaultsRepository extends Repository<Vaults, Vault> {
  new(super.db);

  @override
  TableInfo<Vaults, Vault> get table => db.vaults;
}
