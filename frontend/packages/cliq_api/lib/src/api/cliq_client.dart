import 'package:cliq_api/cliq_api.dart';

import '../impl/requests/model/rest_response.dart';
import '../impl/requests/request_handler.dart';

class RouteOptions {
  Uri? hostUri;
}

abstract class CliqClient {
  RouteOptions get routeOptions;
  User get selfUser;

  static Future<String> retrieveHealthStatus(RouteOptions routeOptions) async {
    final RestResponse<String> response = await RequestHandler.request(
      route: ActuatorRoutes.getHealth.compile(),
      mapper: (json) => json['status'] as String,
      routeOptions: routeOptions,
    );
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }
}
