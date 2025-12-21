import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';
import 'package:cliq_api/src/impl/requests/model/rest_response.dart';

import '../../../api/exceptions/server_exception.dart';

enum ApiError {
  /* Not thrown by the server directly, but still server-related */
  internalServerError(0000, 'Internal server error!'),
  serviceUnavailable(0001, 'Service unavailable!'),

  /* Authentication errors */
  invalidSession(1000, 'Invalid session!'),
  sessionLimitReached(1001, 'Session limit reached!'),
  invalidCredentials(1002, 'Invalid credentials provided!'),
  unauthorized(1004, 'Unauthorized!'),
  noTokenProvided(1006, 'No bearer token provided!'),

  /* Client errors */
  resourceNotFound(1100, 'Requested resource was not found!'),
  serializationError(1101, 'Serialization error!'),
  missingPermissions(1102, 'Missing permissions!'),

  /* Validation errors */
  jsonPayloadValidationError(1200, 'JSON payload validation error!'),
  genericValidationError(1201, 'Validation error!'),

  /* Server errors */
  entityError(1300, "DB-Entity error!"),
  dbError(1301, "Database error!"),
  redisError(1302, "Redis error!"),

  /* Misc errors */
  actixError(9000, "Actix error!"),
  unknown(9999, 'Unknown error!');

  final int code;
  final String message;

  const ApiError(this.code, this.message);

  // TODO: replace this with status code in the future

  static ApiError? fromCode(int errorCode) {
    for (ApiError value in ApiError.values) {
      if (value.code == errorCode) {
        return value;
      }
    }
    return null;
  }

  CliqApiException toException() => ServerException(this);
  RestResponse<T> toResponse<T>({required int? statusCode}) =>
      RestResponse<T>(error: toException(), statusCode: statusCode);
}
