import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';

/// Represents a response from a REST request.
/// This can either hold data, [T], or an [ErrorResponse].
class RestResponse<T> {
  final T? data;
  final CliqApiException? error;
  final int? statusCode;

  const RestResponse({this.data, this.error, required this.statusCode});

  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get hasStatusCode => statusCode != null;
}
