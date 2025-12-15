import 'package:cliq_api/src/api/cliq_client.dart';
import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'model/api_error.dart';
import 'model/client_error.dart';
import 'model/error_response.dart';
import 'model/rest_response.dart';
import 'model/route.dart';

/// Utility class for handling requests.
class RequestHandler {
  static final Logger _log = Logger('RequestHandler');

  final CliqClient api;

  const RequestHandler(this.api);

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
        statusCode: response.statusCode,
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
    Map<int, ApiError> errorMap = const {},
    String contentType = 'application/json',
  }) async {
    try {
      final Response<dynamic> response = await route.submit(
        routeOptions: routeOptions,
        body: body,
        bearerToken: bearerToken,
        contentType: contentType,
      );
      return RestResponse(data: true, statusCode: response.statusCode);
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
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  static Future<RestResponse<T>> _handleDioException<T>(DioException ex) async {
    // check if error response is present
    final ErrorResponse? errorResponse = ErrorResponse.tryFromJson(
      ex.response?.data,
    );
    if (errorResponse != null) {
      if (errorResponse.error != null) {
        return errorResponse.error!.toResponse(
          statusCode: ex.response?.statusCode,
        );
      }
      _log.warning(
        'Encountered unknown ErrorResponse: ${errorResponse.details}',
      );
    }
    // if not, check status code
    final int? statusCode = ex.response?.statusCode;
    if (statusCode != null) {
      final CliqApiException? ex = switch (statusCode) {
        400 => ClientError.badRequest.toException(),
        500 => ApiError.internalServerError.toException(),
        503 => ApiError.serviceUnavailable.toException(),
        _ => null,
      };
      if (ex != null) {
        return RestResponse(error: ex, statusCode: statusCode);
      }
    }
    // if this also fails, check timeout or if the server is unreachable
    if (ex.type == DioExceptionType.connectionTimeout ||
        ex.type == DioExceptionType.receiveTimeout) {
      return ClientError.serverUnreachable.toResponse(statusCode: statusCode);
    }
    if (ex.type == DioExceptionType.connectionError) {
      return ClientError.invalidUri.toResponse(statusCode: statusCode);
    }
    _log.warning('Unknown error occurred: ${ex.message}, ${ex.stackTrace}');
    return ApiError.unknown.toResponse(statusCode: statusCode);
  }
}
