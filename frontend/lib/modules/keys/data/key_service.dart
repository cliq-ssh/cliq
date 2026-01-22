import 'package:cliq/modules/keys/data/key_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart' show Value;

import '../../../shared/extensions/value.extension.dart';

final class KeyService {
  final KeyRepository keyRepository;

  const KeyService(this.keyRepository);

  Stream<List<int>> watchAll() => keyRepository.db.findAllKeyIds().watch();

  Future<List<Key>> findByIds(List<int> ids) {
    return keyRepository.db.findKeyByIds(ids).get();
  }

  Future<int> createKey({
    required String label,
    required String privatePem,
    required String? passphrase,
  }) => keyRepository.insert(
    KeysCompanion.insert(
      label: label.trim(),
      privatePem: privatePem.trim(),
      passphrase: Value.absentIfNull(passphrase),
    ),
  );

  Future<int> update(
    int id, {
    required String? label,
    required String? privatePem,
    required String? passphrase,
    KeysCompanion? compareTo,
  }) => keyRepository.updateById(
    id,
    KeysCompanion(
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

  Future<void> deleteById(int id) => keyRepository.deleteById(id);
}
