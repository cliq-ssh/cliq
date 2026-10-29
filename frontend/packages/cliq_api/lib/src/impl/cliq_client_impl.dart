import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/requests/request_handler.dart';
import 'package:cliq_api/src/impl/utils/encryption_helper.dart';

import 'entity_builder.dart';

class CliqClientImpl implements CliqClient {
  @override
  RouteOptions routeOptions = RouteOptions();

  late final RequestHandler requestHandler = .new(this);
  late final EntityBuilder entityBuilder = .new(this);

  @override
  late final User selfUser;

  late String accessToken;

  final EncryptionHelper encryptionHelper = .new();

  @override
  Future<User> retrieveSelfUser() async {
    final result = await requestHandler.authenticatedRequest(
      route: UserRoutes.getMe.compile(),
      mapper: (data) => entityBuilder.buildUser(data),
    );

    if (result.hasError) {
      throw result.error!;
    }
    return result.data!;
  }

  @override
  Future<Vault> retrieveVault({required String vaultId}) async {
    final result = await requestHandler.authenticatedRequest(
      route: VaultRoutes.get.compile(params: [vaultId]),
      mapper: (data) => entityBuilder.buildVault(data),
    );

    if (result.hasError) {
      throw result.error!;
    }
    return result.data!;
  }

  @override
  Future<DateTime?> retrieveVaultLastUpdated({required String vaultId}) async {
    final result = await requestHandler.authenticatedRequest(
      route: VaultRoutes.getLastUpdated.compile(params: [vaultId]),
      mapper: (data) => DateTime.tryParse(data),
    );

    if (result.hasError) {
      throw result.error!;
    }
    return result.data;
  }

  @override
  Future<void> upsertVault({
    required String vaultId,
    required String configuration,
  }) async {
    final result = await requestHandler.authenticatedNoResponseRequest(
      route: VaultRoutes.put.compile(params: [vaultId]),
      body: {'configuration': configuration, 'version': '_unused'},
    );

    if (result.hasError) {
      throw result.error!;
    }
  }
}
