import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';
import 'package:cliq_api/src/impl/requests/model/rest_response.dart';

import '../../../api/exceptions/client_exception.dart';

enum ClientError {
  badRequest('Bad request'),

  noNetworkConnection('No network connection'),
  serverUnreachable('Server is unreachable'),
  invalidUri('Invalid URI');

  final String message;

  const ClientError(this.message);

  CliqApiException toException() => ClientException(this);
  RestResponse<T> toResponse<T>({required int? statusCode}) =>
      RestResponse<T>(error: toException(), statusCode: statusCode);
}
