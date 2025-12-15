import 'package:cliq_api/cliq_api.dart';

import '../impl/requests/model/rest_response.dart';
import '../impl/requests/request_handler.dart';

class RouteOptions {
  Uri? hostUri;
}

abstract class CliqClient {
  RouteOptions get routeOptions;
  Session get session;

  static Future<String> retrieveHealthStatus(RouteOptions routeOptions) async {
    final RestResponse<String> response = await RequestHandler.request(
      route: ServerRoutes.getHealth.compile(),
      mapper: (json) => json['status'] as String,
      routeOptions: routeOptions,
    );
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }

  Future<User> createUser({
    required String email,
    required String password,
    required String username,
    String locale = 'en',
  });

  Future<UserConfig> retrieveUserConfig();
  Future<DateTime?> retrieveUserConfigLastUpdated();
}
