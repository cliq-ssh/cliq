import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/filterable.dart';

class KnownHostFull extends KnownHost implements Filterable {
  final Vault vault;

  const new(
    this.vault, {
    required super.id,
    required super.vaultId,
    required super.host,
    required super.hostKey,
    required super.createdAt,
  });

  new fromKnownHost(KnownHost knownHost, {required this.vault})
    : super(
        id: knownHost.id,
        vaultId: knownHost.vaultId,
        host: knownHost.host,
        hostKey: knownHost.hostKey,
        createdAt: knownHost.createdAt,
      );

  factory fromFindAllResult(FindAllKnownHostsFullResult result) {
    return KnownHostFull.fromKnownHost(result.knownHost, vault: result.vault);
  }

  @override
  List<String> getFilterableFields() => [?vault.owner, host];
}
