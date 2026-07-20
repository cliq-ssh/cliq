import 'package:cliq_api/cliq_api.dart';

import '../impl/requests/model/rest_response.dart';
import '../impl/requests/request_handler.dart';

class RouteOptions {
  Uri? hostUri;

  RouteOptions({this.hostUri});

  factory RouteOptions.fromJson(Map<String, dynamic> json) {
    return RouteOptions(
      hostUri: json['hostUri'] != null ? Uri.parse(json['hostUri']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'hostUri': hostUri?.toString()};
  }

  @override
  String toString() => 'RouteOptions(hostUri: $hostUri)';
}

abstract class CliqClient {
  RouteOptions get routeOptions;
  User get selfUser;

  static Future<ServerConfigurationResponse> retrieveConfiguration(
    RouteOptions routeOptions,
  ) async {
    final RestResponse<ServerConfigurationResponse> response =
        await RequestHandler.request(
          route: ServerConfigurationRoutes.get.compile(),
          mapper: (json) => .fromJson(json),
          routeOptions: routeOptions,
        );
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }

  Future<User> retrieveSelfUser();

  Future<Vault> retrieveVault();

  Future<DateTime?> retrieveVaultLastUpdated();

  Future<void> upsertVault({required String? configuration});
}
