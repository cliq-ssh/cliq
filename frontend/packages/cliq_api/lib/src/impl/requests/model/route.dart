import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../../api/cliq_client.dart';
import '../../utils/string_utils.dart';

class Route {
  /// The HTTP method of this route.
  final String method;

  /// The path of this route.
  final String path;

  /// The amount of parameters this route expects.
  final int paramCount;

  /// If true, this route is relative to /api
  final bool isApiRoute;

  Route(this.method, this.path, {this.isApiRoute = true})
    : assert(StringUtils.count(path, '{') == StringUtils.count(path, '}')),
      paramCount = StringUtils.count(path, '{');

  Route.get(String path) : this('GET', path);

  Route.post(String path) : this('POST', path);

  Route.put(String path) : this('PUT', path);

  Route.delete(String path) : this('DELETE', path);

  Route.patch(String path) : this('PATCH', path);

  CompiledRoute compile({List<dynamic> params = const []}) {
    if (params.length != paramCount) {
      throw ArgumentError(
        'Error compiling route [$method $path}]: Incorrect amount of parameters! Expected: $paramCount, Provided: ${params.length}',
      );
    }
    final Map<String, String> values = {};
    String compiledRoute = path;
    for (dynamic param in params) {
      int paramStart = compiledRoute.indexOf('{');
      int paramEnd = compiledRoute.indexOf('}');
      values[compiledRoute.substring(paramStart + 1, paramEnd)] = param
          .toString();
      compiledRoute = compiledRoute.replaceRange(
        paramStart,
        paramEnd + 1,
        param.toString(),
      );
    }
    return CompiledRoute(this, compiledRoute, values);
  }
}

class CompiledRoute {
  static final Logger _log = Logger('CompiledRoute');

  final Route baseRoute;
  final String compiledRoute;
  final Map<String, String> parameters;
  Map<String, String>? queryParameters;

  CompiledRoute(
    this.baseRoute,
    this.compiledRoute,
    this.parameters, {
    this.queryParameters,
  });

  CompiledRoute withQueryParams(Map<String, String> params) {
    String newRoute = compiledRoute;
    params.forEach((key, value) {
      newRoute =
          '$newRoute${queryParameters == null || queryParameters!.isEmpty ? '?' : '&'}$key=$value';
      queryParameters ??= {};
      queryParameters![key] = value;
    });
    return CompiledRoute(
      baseRoute,
      newRoute,
      parameters,
      queryParameters: queryParameters,
    );
  }

  Future<Response> submit({
    required RouteOptions routeOptions,
    dynamic body,
    bool isWeb = false,
    String? bearerToken,
    String contentType = 'application/json',
  }) {
    final Dio dio = Dio();
    Map<String, dynamic> headers = {'Content-Type': contentType};
    if (bearerToken != null) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
    return dio
        .fetch(
          RequestOptions(
            path: compiledRoute,
            headers: headers,
            data: body,
            method: baseRoute.method,
            baseUrl: _buildBaseUrl(routeOptions),
          ),
        )
        .then((response) {
          _log.info(
            '${baseRoute.method} $compiledRoute => ${response.statusCode} ${response.statusMessage}',
          );
          return response;
        });
  }

  String _buildBaseUrl(RouteOptions options) {
    String effective = options.hostUri.toString();
    if (effective.endsWith('/')) {
      effective = effective.substring(0, effective.length - 1);
    }
    return baseRoute.isApiRoute ? '$effective/api/v1' : effective;
  }
}
