import 'dart:io';

import 'package:cliq/modules/session/model/sftp_transfer_params.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/session/view/sftp_session_page.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

const _kMinEmitIntervalMillis = 500;
const _kWindowMillis = 3000;

/// Tracks the speed of a file transfer over a sliding window of time.
class _TransferTracker {
  final Stopwatch _stopwatch = Stopwatch()..start();
  final List<MapEntry<int, int>> _samples = [];

  int _lastEmit = -1 << 30;

  /// Records a new sample of bytes transferred and calculates the current transfer speed.
  /// Returns a tuple of (speed in bytes per second, shouldEmit).
  /// shouldEmit is true if enough time has passed since the last emission to warrant sending an update (as defined by [_kMinEmitIntervalMillis]).
  (double? speed, bool shouldEmit) record(int bytes) {
    final now = _stopwatch.elapsedMilliseconds;
    if (now - _lastEmit < _kMinEmitIntervalMillis) return (null, false);
    _lastEmit = now;

    _samples.add(MapEntry(now, bytes));
    _samples.removeWhere((s) => now - s.key > _kWindowMillis);

    if (_samples.length < 2) return (null, true);
    final deltaSeconds = (_samples.last.key - _samples.first.key) / 1000;
    if (deltaSeconds <= 0) return (null, true);
    return ((_samples.last.value - _samples.first.value) / deltaSeconds, true);
  }
}

/// Performs an SFTP transfer in an isolate, sending progress updates back to the main isolate via a [SendPort].
/// This is put into a separate file to avoid complications with isolate spawning and dependencies.
/// See [SessionNotifier.transferSftp] for usage.
Future<void> sftpTransferIsolate(SftpTransferParams p) async {
  SSHClient? sourceClient, destinationClient;
  final speedTracker = _TransferTracker();

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
          final (speed, shouldEmit) = speedTracker.record(bytes);
          if (shouldEmit) {
            p.sendPort.send(
              FileProgressData(
                currentBytes: bytes,
                totalBytes: totalBytes,
                bytesPerSecond: speed,
              ),
            );
          }
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
          final (speed, shouldEmit) = speedTracker.record(uploaded);
          if (shouldEmit) {
            p.sendPort.send(
              FileProgressData(
                currentBytes: uploaded,
                totalBytes: totalBytes,
                bytesPerSecond: speed,
              ),
            );
          }
        }
        return bytes;
      }),
    );
    await remoteFile.close();
  }

  /// Transfers a file from the source SFTP server to the destination SFTP server via a temporary local file.
  /// If both source and destination are the same host, a simple rename is performed instead of a full transfer.
  remoteToRemote() async {
    sourceClient = await connect(p.source!);
    destinationClient = await connect(p.destination!);
    final srcSftp = await sourceClient!.sftp();
    final dstSftp = await destinationClient!.sftp();
    final totalBytes = (await srcSftp.stat(p.sourcePath)).size ?? 0;

    if (listEquals(p.source!.hostKey, p.destination!.hostKey)) {
      await srcSftp.rename(p.sourcePath, p.destinationPath);
      p.sendPort.send(FileProgressData.completed(totalBytes: totalBytes));
      return;
    }

    final pipe = await Pipe.create();
    final remoteFile = await dstSftp.open(
      p.destinationPath,
      mode:
          SftpFileOpenMode.create |
          SftpFileOpenMode.write |
          SftpFileOpenMode.truncate,
    );

    var transferred = 0;

    final writeFuture = remoteFile.write(
      pipe.read.map((chunk) {
        final bytes = Uint8List.fromList(chunk);
        transferred += bytes.length;
        if (totalBytes > 0) {
          final (speed, shouldEmit) = speedTracker.record(transferred);
          if (shouldEmit) {
            p.sendPort.send(
              FileProgressData(
                currentBytes: transferred,
                totalBytes: totalBytes,
                bytesPerSecond: speed,
              ),
            );
          }
        }
        return bytes;
      }),
    );

    await srcSftp
        .download(p.sourcePath, pipe.write)
        .whenComplete(pipe.write.close);

    await writeFuture;
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

    p.sendPort.send(FileProgressData.completed());
  } catch (e) {
    p.sendPort.send(FileProgressData.error(e.toString()));
  } finally {
    sourceClient?.close();
    destinationClient?.close();
  }
}
