import 'package:cliq/modules/keys/data/key_repository.dart';
import 'package:cliq/shared/data/database.dart';

final class KeyService {
  final KeyRepository keyRepository;

  const KeyService(this.keyRepository);

  Stream<List<int>> watchAll() => keyRepository.db.findAllKeyIds().watch();

  Future<List<Key>> findByIds(List<int> ids) {
    return keyRepository.db.findKeyByIds(ids).get();
  }
}
