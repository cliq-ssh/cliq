import 'package:cliq_api/src/api/cliq_client.dart';
import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';
import 'package:cliq_api/src/impl/cliq_client_impl.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'model/error_response.dart';
import 'model/local_errors.dart';
import 'model/rest_response.dart';
import 'model/route.dart';

/// Utility class for handling requests.
class RequestHandler {
  static final Logger _log = Logger('RequestHandler');

  final CliqClientImpl apiImpl;

  const RequestHandler(this.apiImpl);

  /// Tries to execute a request, using the [CompiledRoute] and maps the received data using the
  /// specified [mapper] function, ultimately returning the entity in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<T>> request<T>({
    required CompiledRoute route,
    required T Function(dynamic) mapper,
    required RouteOptions routeOptions,
    String? bearerToken,
    dynamic body,
    String contentType = 'application/json',
  }) async {
    try {
      final Response<dynamic> response = await route.submit(
        routeOptions: routeOptions,
        body: body,
        bearerToken: bearerToken,
        contentType: contentType,
      );
      return RestResponse(
        data: mapper.call(response.data),
        httpStatusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute], without expecting any response.
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<bool>> noResponseRequest<T>({
    required CompiledRoute route,
    required RouteOptions routeOptions,
    String? bearerToken,
    dynamic body,
    String contentType = 'application/json',
  }) async {
    try {
      final Response<dynamic> response = await route.submit(
        routeOptions: routeOptions,
        body: body,
        bearerToken: bearerToken,
        contentType: contentType,
      );
      return RestResponse(data: true, httpStatusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute] and maps the received list of data using the
  /// specified [mapper] function, ultimately returning the list of entities in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<List<T>>> multiRequest<T>({
    required CompiledRoute route,
    required RouteOptions routeOptions,
    String? bearerToken,
    required T Function(dynamic) mapper,
    dynamic body,
    String contentType = 'application/json',
  }) async {
    try {
      final Response<dynamic> response = await route.submit(
        routeOptions: routeOptions,
        body: body,
        bearerToken: bearerToken,
        contentType: contentType,
      );
      if (response.data is! List<dynamic>) {
        throw StateError('Received response is not a list!');
      }
      return RestResponse(
        data: (response.data as List<dynamic>)
            .map((single) => mapper.call(single))
            .toList(),
        httpStatusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  static Future<RestResponse<T>> _handleDioException<T>(DioException ex) async {
    // check if error response is present
    final ErrorResponse? errorResponse = .tryFromJson(ex.response?.data);
    if (errorResponse != null) {
      return errorResponse.toResponse(httpStatusCode: ex.response?.statusCode);
    }

    // if not, check status code
    final int? statusCode = ex.response?.statusCode;
    if (statusCode != null) {
      final CliqException? ex = switch (statusCode) {
        500 => LocalErrors.internalServerError.toException(),
        503 => LocalErrors.serviceUnavailable.toException(),
        _ => null,
      };
      if (ex != null) {
        return RestResponse(error: ex, httpStatusCode: statusCode);
      }
    }

    // if this also fails, check timeout or if the server is unreachable
    if (ex.type == .connectionTimeout ||
        ex.type == .receiveTimeout ||
        ex.type == .connectionError) {
      return LocalErrors.serverUnreachable.toResponse(statusCode: statusCode);
    }
    _log.warning('Unknown error occurred: ${ex.message}, ${ex.stackTrace}');
    return LocalErrors.unknown.toResponse(statusCode: statusCode);
  }

  Future<RestResponse<T>> authenticatedRequest<T>({
    required CompiledRoute route,
    required T Function(dynamic) mapper,
    dynamic body,
    String contentType = 'application/json',
  }) => request(
    route: route,
    mapper: mapper,
    routeOptions: apiImpl.routeOptions,
    bearerToken: apiImpl.accessToken,
    body: body,
    contentType: contentType,
  );

  Future<RestResponse<bool>> authenticatedNoResponseRequest({
    required CompiledRoute route,
    dynamic body,
    String contentType = 'application/json',
  }) => noResponseRequest(
    route: route,
    routeOptions: apiImpl.routeOptions,
    bearerToken: apiImpl.accessToken,
    body: body,
    contentType: contentType,
  );
}
