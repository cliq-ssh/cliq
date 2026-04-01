import '../../../shared/data/database.dart';

class KnownHostFull extends KnownHost {
  final Vault vault;

  const KnownHostFull(
    this.vault, {
    required super.id,
    required super.vaultId,
    required super.host,
    required super.hostKey,
    required super.createdAt,
  });

  KnownHostFull.fromKnownHost(KnownHost knownHost, {required this.vault})
    : super(
        id: knownHost.id,
        vaultId: knownHost.vaultId,
        host: knownHost.host,
        hostKey: knownHost.hostKey,
        createdAt: knownHost.createdAt,
      );

  factory KnownHostFull.fromFindAllResult(FindAllKnownHostsFullResult result) {
    return KnownHostFull.fromKnownHost(result.knownHost, vault: result.vault);
  }
}
