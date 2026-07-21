class CliqException implements Exception {
  final int errorCode;
  final String? description;

  CliqException(this.errorCode, this.description);

  @override
  String toString() => '${runtimeType.toString()}: $description';
}
