class CliqException(final int errorCode, final String? description)
    implements Exception {
  @override
  String toString() => '${runtimeType.toString()}: ($errorCode) $description';
}
