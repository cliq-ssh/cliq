import 'package:cliq/modules/keys/data/key_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart' show Value;

import '../../../shared/extensions/value.extension.dart';
import '../model/key_full.model.dart';

final class KeyService {
  final KeyRepository _keyRepository;

  const KeyService(this._keyRepository);

  Stream<List<int>> watchAll() => _keyRepository.db.findAllKeyIds().watch();

  Future<List<KeyFull>> findByIds(List<int> ids) {
    return _keyRepository.db
        .findAllKeyFullByIds(ids)
        .get()
        .then((keys) => keys.map(KeyFull.fromFindAllResult).toList());
  }

  Future<int> createKey({
    required int vaultId,
    required String label,
    required String privatePem,
    required String? passphrase,
  }) => _keyRepository.insert(
    KeysCompanion.insert(
      vaultId: vaultId,
      label: label.trim(),
      privatePem: privatePem.trim(),
      passphrase: Value.absentIfNull(passphrase),
    ),
  );

  Future<int> update(
    int id, {
    required int? vaultId,
    required String? label,
    required String? privatePem,
    required String? passphrase,
    KeysCompanion? compareTo,
  }) => _keyRepository.updateById(
    id,
    KeysCompanion(
      vaultId: ValueExtension.absentIfNullOrSame(vaultId, compareTo?.vaultId),
      label: ValueExtension.absentIfNullOrSame(label, compareTo?.label),
      privatePem: ValueExtension.absentIfNullOrSame(
        privatePem,
        compareTo?.privatePem,
      ),
      passphrase: ValueExtension.absentIfSame(
        passphrase,
        compareTo?.passphrase.value,
      ),
    ),
  );

  Future<void> deleteById(int id) => _keyRepository.deleteById(id);
}
