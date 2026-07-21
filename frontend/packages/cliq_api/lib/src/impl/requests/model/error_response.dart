import '../../../../cliq_api.dart';
import 'rest_response.dart';

class ErrorResponse {
  final ErrorCode errorCode;

  const ErrorResponse({required this.errorCode});

  static ErrorResponse? tryFromJson(Map<String, dynamic>? json) {
    final ErrorCode? errorCode = .tryFromJson(json?['errorCode']);
    if (errorCode == null) {
      return null;
    }
    return ErrorResponse(errorCode: errorCode);
  }

  CliqException toException() =>
      CliqException(errorCode.code, errorCode.description);
  RestResponse<T> toResponse<T>({required int? httpStatusCode}) =>
      .new(error: toException(), httpStatusCode: httpStatusCode);
}

class ErrorCode {
  final int code;
  final String? description;

  const ErrorCode(this.code, this.description);

  static ErrorCode? tryFromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty || json['code'] == null) {
      return null;
    }
    return ErrorCode(json['code'], json['description']);
  }
}
