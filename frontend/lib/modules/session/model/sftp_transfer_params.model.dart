import 'dart:isolate';
import 'dart:typed_data';

class SftpConnectParams {
  final String host;
  final int port;
  final String username;
  final Uint8List hostKey;

  final String? password;
  final List<String> keyPems;

  const SftpConnectParams({
    required this.host,
    required this.port,
    required this.username,
    required this.hostKey,
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
