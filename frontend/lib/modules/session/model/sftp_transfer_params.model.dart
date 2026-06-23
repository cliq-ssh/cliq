import 'dart:isolate';

class SftpConnectParams {
  final String host;
  final int port;
  final String username;
  final String? password;
  final List<String> keyPems;

  const SftpConnectParams({
    required this.host,
    required this.port,
    required this.username,
    this.password,
    this.keyPems = const [],
  });
}

class SftpTransferParams {
  final SendPort sendPort;
  final SftpConnectParams? source;
  final String sourcePath;
  final SftpConnectParams? destination;
  final String destinationPath;

  const SftpTransferParams({
    required this.sendPort,
    this.source,
    required this.sourcePath,
    this.destination,
    required this.destinationPath,
  });
}
