import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../../api/cliq_client.dart';

enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch;

  @override
  String toString() => name.toUpperCase();
}

class Route {
  /// The [HttpMethod] of this route.
  final HttpMethod method;

  /// The path of this route.
  final String path;

  /// The amount of parameters this route expects.
  /// Defaults to 0.
  final int paramCount;

  const Route(this.method, this.path, {this.paramCount = 0});

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
            method: baseRoute.method.toString(),
            baseUrl: _buildBaseUrl(routeOptions),
          ),
        )
        .then((response) {
          _log.info(
            '${baseRoute.method} $compiledRoute => ${response.statusCode} ${response.statusMessage}',
          );
          return response;
        })
        .onError((DioException? error, stackTrace) {
          _log.severe(
            '${baseRoute.method} $compiledRoute => ${error?.response?.statusCode} ${error?.response?.statusMessage} ${error?.response?.data}',
          );
          throw error!;
        });
  }

  String _buildBaseUrl(RouteOptions options) {
    String effective = options.hostUri.toString();
    if (effective.endsWith('/')) {
      effective = effective.substring(0, effective.length - 1);
    }
    return effective;
  }
}
