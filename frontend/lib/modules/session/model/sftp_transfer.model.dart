import 'dart:io';

import 'package:cliq/modules/session/model/sftp_transfer_params.model.dart';
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

/// A single file to transfer. [relativePath] is '' when this represents a lone file
/// (i.e. no directory is involved), in which case the source/destination root paths
/// are used directly instead of being joined with a sub-path
class _FileEntry {
  final String relativePath;
  final int size;
  _FileEntry(this.relativePath, this.size);
}

/// Recursively lists all files under [root]
Future<List<_FileEntry>> _listRemoteFilesRecursive(
  SftpClient sftp,
  String root,
) async {
  final entries = <_FileEntry>[];

  Future<void> walk(String relative) async {
    final path = relative.isEmpty ? root : '$root/$relative';
    for (final e in await sftp.listdir(path)) {
      if (e.filename == '.' || e.filename == '..') continue;
      final childRelative = relative.isEmpty
          ? e.filename
          : '$relative/${e.filename}';
      if (e.attr.isDirectory) {
        await walk(childRelative);
      } else {
        entries.add(_FileEntry(childRelative, e.attr.size ?? 0));
      }
    }
  }

  await walk('');
  return entries;
}

/// Recursively lists all files under [root] on the local filesystem
Future<List<_FileEntry>> _listLocalFilesRecursive(String root) async {
  final entries = <_FileEntry>[];
  await for (final entity in Directory(
    root,
  ).list(recursive: true, followLinks: false)) {
    if (entity is File) {
      final relative = entity.path
          .substring(root.length + 1)
          .replaceAll(Platform.pathSeparator, '/');
      entries.add(_FileEntry(relative, await entity.length()));
    }
  }
  return entries;
}

String _localJoin(String root, String relative) =>
    '$root${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}';

Future<void> _ensureRemoteDir(SftpClient sftp, String path) async {
  try {
    await sftp.mkdir(path);
  } on SftpStatusError catch (_) {
    // already exists
  }
}

/// Creates [root] and every intermediate directory implied by [entries] on the remote side
Future<void> _createRemoteDirsForEntries(
  SftpClient sftp,
  String root,
  List<_FileEntry> entries,
) async {
  final dirs = <String>{};
  for (final e in entries) {
    final parts = e.relativePath.split('/');
    for (var i = 1; i < parts.length; i++) {
      dirs.add(parts.sublist(0, i).join('/'));
    }
  }
  final sorted = dirs.toList()
    ..sort((a, b) => a.split('/').length.compareTo(b.split('/').length));

  await _ensureRemoteDir(sftp, root);
  for (final d in sorted) {
    await _ensureRemoteDir(sftp, '$root/$d');
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

  /// Downloads a file (or, if [p.sourcePath] is a directory, every file within it)
  /// from the source SFTP server to the local destination path
  remoteToLocal() async {
    sourceClient = await connect(p.source!);
    final sftp = await sourceClient!.sftp();

    final stat = await sftp.stat(p.sourcePath);

    final List<_FileEntry> entries;
    if (stat.isDirectory) {
      entries = await _listRemoteFilesRecursive(sftp, p.sourcePath);
      Directory(p.destinationPath).createSync(recursive: true);
    } else {
      entries = [_FileEntry('', stat.size ?? 0)];
    }

    final totalBytes = entries.fold<int>(0, (sum, e) => sum + e.size);
    var completedBytes = 0;

    for (final e in entries) {
      final remotePath = e.relativePath.isEmpty
          ? p.sourcePath
          : '${p.sourcePath}/${e.relativePath}';
      final localPath = e.relativePath.isEmpty
          ? p.destinationPath
          : _localJoin(p.destinationPath, e.relativePath);
      if (e.relativePath.isNotEmpty) {
        File(localPath).parent.createSync(recursive: true);
      }

      final sink = File(localPath).openWrite();
      final baseCompleted = completedBytes;
      await sftp.download(
        remotePath,
        sink,
        onProgress: (bytes) {
          if (totalBytes > 0) {
            final overall = baseCompleted + bytes;
            final (speed, shouldEmit) = speedTracker.record(overall);
            if (shouldEmit) {
              p.sendPort.send(
                FileProgressData(
                  currentBytes: overall,
                  totalBytes: totalBytes,
                  bytesPerSecond: speed,
                ),
              );
            }
          }
        },
      );
      await sink.close();
      completedBytes += e.size;
    }
  }

  /// Uploads a file (or, if [p.sourcePath] is a directory, every file within it)
  /// from the local source path to the destination SFTP server
  localToRemote() async {
    destinationClient = await connect(p.destination!);
    final sftp = await destinationClient!.sftp();
    final isDir =
        await FileSystemEntity.type(p.sourcePath) ==
        FileSystemEntityType.directory;

    final List<_FileEntry> entries;
    if (isDir) {
      entries = await _listLocalFilesRecursive(p.sourcePath);
      await _createRemoteDirsForEntries(sftp, p.destinationPath, entries);
    } else {
      entries = [_FileEntry('', await File(p.sourcePath).length())];
    }

    final totalBytes = entries.fold<int>(0, (sum, e) => sum + e.size);
    var completedBytes = 0;

    for (final e in entries) {
      final localFile = e.relativePath.isEmpty
          ? File(p.sourcePath)
          : File(_localJoin(p.sourcePath, e.relativePath));
      final remotePath = e.relativePath.isEmpty
          ? p.destinationPath
          : '${p.destinationPath}/${e.relativePath}';

      final remoteFile = await sftp.open(
        remotePath,
        mode:
            SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );

      var uploadedForFile = 0;
      final baseCompleted = completedBytes;
      await remoteFile.write(
        localFile.openRead().map((chunk) {
          final bytes = Uint8List.fromList(chunk);
          uploadedForFile += bytes.length;
          if (totalBytes > 0) {
            final overall = baseCompleted + uploadedForFile;
            final (speed, shouldEmit) = speedTracker.record(overall);
            if (shouldEmit) {
              p.sendPort.send(
                FileProgressData(
                  currentBytes: overall,
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
      completedBytes += e.size;
    }
  }

  /// Transfers a file (or, if [p.sourcePath] is a directory, every file within it) from
  /// the source SFTP server to the destination SFTP server via a temporary local pipe.
  /// If both source and destination are the same host, a simple rename is performed
  /// instead
  remoteToRemote() async {
    sourceClient = await connect(p.source!);
    destinationClient = await connect(p.destination!);
    final srcSftp = await sourceClient!.sftp();
    final dstSftp = await destinationClient!.sftp();
    final srcStat = await srcSftp.stat(p.sourcePath);

    if (listEquals(p.source!.hostKey, p.destination!.hostKey)) {
      await srcSftp.rename(p.sourcePath, p.destinationPath);
      p.sendPort.send(
        FileProgressData.completed(totalBytes: srcStat.size ?? 0),
      );
      return;
    }

    final List<_FileEntry> entries;
    if (srcStat.isDirectory) {
      entries = await _listRemoteFilesRecursive(srcSftp, p.sourcePath);
      await _createRemoteDirsForEntries(dstSftp, p.destinationPath, entries);
    } else {
      entries = [_FileEntry('', srcStat.size ?? 0)];
    }

    final totalBytes = entries.fold<int>(0, (sum, e) => sum + e.size);
    var completedBytes = 0;

    for (final e in entries) {
      final srcPath = e.relativePath.isEmpty
          ? p.sourcePath
          : '${p.sourcePath}/${e.relativePath}';
      final dstPath = e.relativePath.isEmpty
          ? p.destinationPath
          : '${p.destinationPath}/${e.relativePath}';

      final pipe = await Pipe.create();
      final remoteFile = await dstSftp.open(
        dstPath,
        mode:
            SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );

      var transferredForFile = 0;
      final baseCompleted = completedBytes;
      final writeFuture = remoteFile.write(
        pipe.read.map((chunk) {
          final bytes = Uint8List.fromList(chunk);
          transferredForFile += bytes.length;
          if (totalBytes > 0) {
            final overall = baseCompleted + transferredForFile;
            final (speed, shouldEmit) = speedTracker.record(overall);
            if (shouldEmit) {
              p.sendPort.send(
                FileProgressData(
                  currentBytes: overall,
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
          .download(srcPath, pipe.write)
          .whenComplete(pipe.write.close);
      await writeFuture;
      await remoteFile.close();
      completedBytes += e.size;
    }
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
