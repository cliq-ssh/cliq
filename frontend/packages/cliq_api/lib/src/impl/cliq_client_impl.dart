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
  Future<List<PartialVault>> listVaults() async {
    final result = await RequestHandler.multiRequest(
      route: VaultRoutes.list.compile(),
      mapper: (data) => entityBuilder.buildPartialVault(data),
      routeOptions: routeOptions,
      bearerToken: accessToken,
    );

    if (result.hasError) {
      throw result.error!;
    }
    return result.data!;
  }

  @override
  Future<Vault> retrieveVault({required String id}) async {
    final result = await requestHandler.authenticatedRequest(
      route: VaultRoutes.get.compile(params: [id]),
      mapper: (data) => entityBuilder.buildVault(data),
    );

    if (result.hasError) {
      throw result.error!;
    }
    return result.data!;
  }

  @override
  Future<DateTime?> retrieveVaultLastUpdated({required String id}) async {
    final result = await requestHandler.authenticatedRequest(
      route: VaultRoutes.getLastUpdated.compile(params: [id]),
      mapper: (data) => DateTime.tryParse(data),
    );

    if (result.hasError) {
      throw result.error!;
    }
    return result.data;
  }

  @override
  Future<void> upsertVault({
    required String id,
    required String configuration,
  }) async {
    final result = await requestHandler.authenticatedNoResponseRequest(
      route: VaultRoutes.put.compile(params: [id]),
      body: {'configuration': configuration, 'version': '_unused'},
    );

    if (result.hasError) {
      throw result.error!;
    }
  }
}
