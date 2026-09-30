import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';
import 'package:cliq_api/src/impl/requests/model/rest_response.dart';

/// These errors are used to represent issues that occur on the client side or during the
/// communication with the server, rather than being specific error responses from the server itself.
enum LocalErrors(final int code, final String description) {
  /* Not thrown by the server directly, but still server-related */
  internalServerError(0101, 'Internal server error'),
  serviceUnavailable(0102, 'Service unavailable'),
  badGateway(0105, 'Bad gateway'),

  /* Client errors */
  noNetworkConnection(0103, 'No network connection'),
  serverUnreachable(0104, 'Server is unreachable'),

  /* Misc */
  unknown(0199, 'Unknown error!');

  CliqException toException() => CliqException(code, description);
  RestResponse<T> toResponse<T>({required int? statusCode}) =>
      RestResponse<T>(error: toException(), httpStatusCode: statusCode);
}
