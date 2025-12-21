abstract class CliqApiException implements Exception {
  final String? message;

  CliqApiException(this.message);

  @override
  String toString() => '${runtimeType.toString()}: $message';
}
