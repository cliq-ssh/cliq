import '../../../shared/data/database.dart';

class KeyFull extends Key {
  final Vault vault;

  const KeyFull(
    this.vault, {
    required super.id,
    required super.vaultId,
    required super.label,
    required super.passphrase,
    required super.privatePem,
  });

  KeyFull.fromKey(Key key, {required this.vault})
    : super(
        id: key.id,
        vaultId: key.vaultId,
        label: key.label,
        passphrase: key.passphrase,
        privatePem: key.privatePem,
      );

  factory KeyFull.fromFindAllResult(FindAllKeyFullByIdsResult result) {
    return KeyFull.fromKey(result.keyEntity, vault: result.vault);
  }
}
