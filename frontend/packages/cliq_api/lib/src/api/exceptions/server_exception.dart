import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';

import '../../impl/requests/model/api_error.dart';

class ServerException extends CliqApiException {
  final ApiError error;

  ServerException(this.error) : super(error.message);

  @override
  String toString() => '${runtimeType.toString()}: $message (${error.code})';
}
