import '../../../../cliq_api.dart';
import 'rest_response.dart';

class ErrorResponse._({required final ErrorCode errorCode}) {
  static ErrorResponse? tryFromJson(Map<String, dynamic>? json) {
    final ErrorCode? errorCode = .tryFromJson(json?['errorCode']);
    if (errorCode == null) {
      return null;
    }
    return ErrorResponse._(errorCode: errorCode);
  }

  CliqException toException() =>
      CliqException(errorCode.code, errorCode.description);
  RestResponse<T> toResponse<T>({required int? httpStatusCode}) =>
      .new(error: toException(), httpStatusCode: httpStatusCode);
}

class const ErrorCode._(final int code, final String? description) {
  static ErrorCode? tryFromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty || json['code'] == null) {
      return null;
    }
    return ErrorCode._(json['code'], json['description']);
  }
}
