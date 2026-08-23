import 'package:cliq/shared/data/database.dart';

class KeyFull extends Key {
  final Vault vault;

  const new(
    this.vault, {
    required super.id,
    required super.vaultId,
    required super.label,
    required super.passphrase,
    required super.privateKey,
    required super.publicKey,
  });

  new fromKey(Key key, {required this.vault})
    : super(
        id: key.id,
        vaultId: key.vaultId,
        label: key.label,
        passphrase: key.passphrase,
        privateKey: key.privateKey,
        publicKey: key.publicKey,
      );

  factory fromFindAllResult(FindAllKeyFullByIdsResult result) {
    return KeyFull.fromKey(result.keyEntity, vault: result.vault);
  }
}
