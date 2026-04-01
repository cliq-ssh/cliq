import 'package:cliq/modules/vaults/data/vault_service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<VaultService> vaultServiceProvider = Provider(
  (ref) => VaultService(ref.read(databaseProvider).vaultsRepository),
);
