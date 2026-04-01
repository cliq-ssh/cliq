import 'package:cliq/modules/keys/data/key_service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<KeyService> keyServiceProvider = Provider(
  (ref) => KeyService(ref.read(databaseProvider).keysRepository),
);
