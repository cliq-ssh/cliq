import 'dart:io';
import 'dart:typed_data';

import 'package:cliq/modules/session/model/sftp_transfer_params.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:dartssh2/dartssh2.dart';

/// Performs an SFTP transfer in an isolate, sending progress updates back to the main isolate via a [SendPort].
/// This is put into a separate file to avoid complications with isolate spawning and dependencies.
/// See [SessionNotifier.transferSftp] for usage.
Future<void> sftpTransferIsolate(SftpTransferParams p) async {
  SSHClient? sourceClient, destinationClient;

  connect(SftpConnectParams c) async {
    return SSHClient(
      await SSHSocket.connect(c.host, c.port),
      username: c.username,
      onPasswordRequest: c.password != null ? () => c.password! : null,
      identities: c.keyPems.isNotEmpty
          ? c.keyPems.map(SSHKeyPair.fromPem).expand((k) => k).toList()
          : null,
    );
  }

  /// Downloads a file from the source SFTP server to the local destination path
  remoteToLocal() async {
    sourceClient = await connect(p.source!);
    final sftp = await sourceClient!.sftp();

    final stat = await sftp.stat(p.sourcePath);
    final totalBytes = stat.size ?? 0;

    final sink = File(p.destinationPath).openWrite();

    await sftp.download(
      p.sourcePath,
      sink,
      onProgress: (bytes) {
        if (totalBytes > 0) {
          p.sendPort.send((bytes / totalBytes).clamp(0.0, 0.99));
        }
      },
    );
    await sink.close();
  }

  /// Uploads a file from the local source path to the destination SFTP server
  localToRemote() async {
    destinationClient = await connect(p.destination!);
    final sftp = await destinationClient!.sftp();

    final localFile = File(p.sourcePath);
    final totalBytes = await localFile.length();

    final remoteFile = await sftp.open(
      p.destinationPath,
      mode:
          SftpFileOpenMode.create |
          SftpFileOpenMode.write |
          SftpFileOpenMode.truncate,
    );

    var uploaded = 0;
    await remoteFile.write(
      localFile.openRead().map((chunk) {
        final bytes = Uint8List.fromList(chunk);
        uploaded += bytes.length;
        if (totalBytes > 0) {
          p.sendPort.send((uploaded / totalBytes).clamp(0.0, 0.99));
        }
        return bytes;
      }),
    );
    await remoteFile.close();
  }

  /// Transfers a file from the source SFTP server to the destination SFTP server via a temporary local file.
  remoteToRemote() async {
    sourceClient = await connect(p.source!);
    destinationClient = await connect(p.destination!);
    final srcSftp = await sourceClient!.sftp();
    final dstSftp = await destinationClient!.sftp();
    final totalBytes = (await srcSftp.stat(p.sourcePath)).size ?? 0;

    final pipe = await Pipe.create();
    final remoteFile = await dstSftp.open(
      p.destinationPath,
      mode:
          SftpFileOpenMode.create |
          SftpFileOpenMode.write |
          SftpFileOpenMode.truncate,
    );

    var transferred = 0;

    remoteFile.write(
      pipe.read.map((chunk) {
        final bytes = Uint8List.fromList(chunk);
        transferred += bytes.length;
        if (totalBytes > 0) {
          p.sendPort.send((transferred / totalBytes).clamp(0.0, 0.99));
        }
        return bytes;
      }),
    );

    await srcSftp
        .download(p.sourcePath, pipe.write)
        .whenComplete(pipe.write.close);

    await remoteFile.close();
  }

  try {
    await (switch ((p.source != null, p.destination != null)) {
      (true, false) => remoteToLocal(),
      (false, true) => localToRemote(),
      (true, true) => remoteToRemote(),
      _ => throw UnimplementedError(
        'Both source and destination cannot be local.',
      ),
    });

    p.sendPort.send(1.0);
  } catch (_) {
    p.sendPort.send(-1.0);
  } finally {
    sourceClient?.close();
    destinationClient?.close();
  }
}
