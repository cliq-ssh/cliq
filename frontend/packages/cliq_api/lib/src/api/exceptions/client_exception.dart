import 'package:cliq_api/src/api/exceptions/cliq_api_exception.dart';

import '../../impl/requests/model/client_error.dart';

class ClientException extends CliqApiException {
  final ClientError error;

  ClientException(this.error) : super(error.message);

  @override
  String toString() => '${runtimeType.toString()}: $message';
}
