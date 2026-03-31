import 'package:cliq/modules/credentials/data/credential_service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<CredentialService> credentialServiceProvider = Provider(
  (ref) => CredentialService(ref.read(databaseProvider).credentialsRepository),
);
