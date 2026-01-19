import 'package:cliq/modules/keys/data/key_repository.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart' show Value;

final class KeyService {
  final KeyRepository keyRepository;

  const KeyService(this.keyRepository);

  Stream<List<int>> watchAll() => keyRepository.db.findAllKeyIds().watch();

  Future<List<Key>> findByIds(List<int> ids) {
    return keyRepository.db.findKeyByIds(ids).get();
  }

  Future<int> createKey(
    String label,
    String privatePem, {
    String? passphrase,
  }) => keyRepository.insert(
    KeysCompanion.insert(
      label: label,
      privatePem: privatePem,
      passphrase: Value.absentIfNull(passphrase),
    ),
  );
  Future<int> update(int id, KeysCompanion key) =>
      keyRepository.updateById(id, key);

  Future<void> deleteById(int id) => keyRepository.deleteById(id);
}
