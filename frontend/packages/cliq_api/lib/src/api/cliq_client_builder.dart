import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/entities/session_impl.dart';
import 'package:cliq_api/src/impl/requests/request_handler.dart';
import 'package:logging/logging.dart';

import '../impl/cliq_client_impl.dart';
import '../impl/requests/model/rest_response.dart';

class CliqClientBuilder {
  static final Logger _log = Logger('CliqClientBuilder');

  final RouteOptions routeOptions;

  CliqClientBuilder({required this.routeOptions});

  Future<CliqClient> loginFromToken(String token) async {
    return _handleAuthProcess((apiImpl) async {
      return RestResponse(
        statusCode: 200,
        data: SessionImpl(
          apiImpl,
          id: -1,
          token: token,
          name: 'name',
          userAgent: 'userAgent',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  Future<CliqClient> login({
    required String email,
    required String password,
  }) async {
    return _handleAuthProcess((apiImpl) {
      return RequestHandler.request(
        route: SessionRoutes.create.compile(),
        routeOptions: routeOptions,
        body: {
          'email': email,
          'password': password,
          'userAgent': 'cliq_api_dart',
        },
        mapper: (json) => apiImpl.entityBuilder.buildSession(json),
      );
    });
  }

  Future<CliqClient> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return _handleAuthProcess((apiImpl) async {
      final User user = await apiImpl.createUser(
        username: username,
        password: password,
        email: email,
      );
      return RequestHandler.request(
        route: SessionRoutes.create.compile(),
        routeOptions: routeOptions,
        // TODO: get real user agent
        body: {
          'email': user.email,
          'password': password,
          'name': user.name,
          'userAgent': 'cliq_api_dart',
        },
        mapper: (json) => apiImpl.entityBuilder.buildSession(json),
      );
    });
  }

  Future<CliqClient> _handleAuthProcess(
    Future<RestResponse<Session>> Function(CliqClientImpl) authFunction,
  ) async {
    // check if the URI is valid and the API is healthy
    final String statusResponse = await CliqClient.retrieveHealthStatus(
      routeOptions,
    );
    _log.config(
      'Successfully connected to: ${routeOptions.hostUri}, status: $statusResponse',
    );
    // build api instance
    final CliqClientImpl apiImpl = CliqClientImpl()
      ..routeOptions = routeOptions;

    // call auth function
    final RestResponse<Session> response = await authFunction(apiImpl);
    if (response.hasError) {
      throw response.error!;
    }
    if (response.data is! Session) {
      throw ArgumentError('The response data is not a session');
    }
    apiImpl.session = response.data!;

    return apiImpl;
  }
}
