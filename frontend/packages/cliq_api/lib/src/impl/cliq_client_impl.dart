import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/requests/request_handler.dart';

import 'entity_builder.dart';
import 'requests/model/rest_response.dart';

class CliqClientImpl implements CliqClient {
  @override
  RouteOptions routeOptions = RouteOptions();

  late final RequestHandler requestHandler = RequestHandler(this);
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);

  @override
  late final Session session;

  @override
  Future<User> createUser({
    required String email,
    required String password,
    required String username,
    String locale = 'en',
  }) {
    return RequestHandler.request(
      route: UserRoutes.create.compile(),
      routeOptions: routeOptions,
      body: {
        'email': email,
        'password': password,
        'username': username,
        'locale': locale,
      },
      mapper: (data) => entityBuilder.buildUser(data),
    ).then((response) {
      if (response.hasError) {
        throw response.error!;
      }
      return response.data!;
    });
  }

  @override
  Future<UserConfig> retrieveUserConfig() async {
    final RestResponse<UserConfig> response = await RequestHandler.request(
      route: UserConfigRoutes.get.compile(),
      routeOptions: routeOptions,
      bearerToken: session.token,
      mapper: (data) => entityBuilder.buildUserConfig(data),
    );
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }

  @override
  Future<DateTime?> retrieveUserConfigLastUpdated() async {
    final RestResponse<DateTime?> response = await RequestHandler.request(
      route: UserConfigRoutes.getLastUpdated.compile(),
      routeOptions: routeOptions,
      bearerToken: session.token,
      mapper: (data) {
        if (data == null || data.toString().isEmpty) {
          return null;
        }
        return DateTime.parse(data as String);
      },
    );
    if (response.hasError) {
      throw response.error!;
    }
    return response.data;
  }
}
