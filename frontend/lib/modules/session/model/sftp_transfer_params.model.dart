import 'dart:isolate';
import 'dart:typed_data';

enum SftpTransferType { localToRemote, remoteToLocal, remoteToRemote }

class SftpConnectParams {
  final String host;
  final int port;
  final String username;
  final Uint8List? hostKey;

  final String? password;
  final List<String> keyPems;
  final List<String?> keyPassphrases;
  final bool skipHostKeyVerification;

  const new({
    required this.host,
    required this.port,
    required this.username,
    this.hostKey,
    this.password,
    this.keyPems = const [],
    this.keyPassphrases = const [],
    this.skipHostKeyVerification = false,
  });
}

class SftpTransferParams {
  final SendPort sendPort;
  final SftpConnectParams? source;
  final String sourcePath;
  final SftpConnectParams? destination;
  final String destinationPath;

  const new({
    required this.sendPort,
    this.source,
    required this.sourcePath,
    this.destination,
    required this.destinationPath,
  });
}
