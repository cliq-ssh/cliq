import 'dart:io';

import 'package:cliq/modules/session/model/sftp_client.model.dart';
import 'package:cliq/modules/session/model/sftp_transfer_params.model.dart';
import 'package:cliq/modules/session/page/sftp_session.page.dart';
import 'package:cliq/src/rust/api/ssh.dart';
import 'package:cliq/src/rust/frb_generated.dart';
import 'package:flutter/foundation.dart';

const _kMinEmitIntervalMillis = 500;
const _kWindowMillis = 3000;
const _kChunkSize = 1024 * 1024;

class _TransferTracker {
  final Stopwatch _stopwatch = Stopwatch()..start();
  final List<MapEntry<int, int>> _samples = [];
  int _lastEmit = -1 << 30;

  (double? speed, bool shouldEmit) record(int bytes) {
    final now = _stopwatch.elapsedMilliseconds;
    if (now - _lastEmit < _kMinEmitIntervalMillis) return (null, false);
    _lastEmit = now;
    _samples.add(MapEntry(now, bytes));
    _samples.removeWhere((sample) => now - sample.key > _kWindowMillis);
    if (_samples.length < 2) return (null, true);
    final seconds = (_samples.last.key - _samples.first.key) / 1000;
    if (seconds <= 0) return (null, true);
    return ((_samples.last.value - _samples.first.value) / seconds, true);
  }
}

class _FileEntry {
  final String relativePath;
  final int size;
  const new(this.relativePath, this.size);
}

Future<List<_FileEntry>> _listRemoteFilesRecursive(
  SftpClient sftp,
  String root,
) async {
  final entries = <_FileEntry>[];
  Future<void> walk(String relative) async {
    final path = relative.isEmpty ? root : '$root/$relative';
    for (final entry in await sftp.listdir(path)) {
      if (entry.filename == '.' || entry.filename == '..') continue;
      final child = relative.isEmpty
          ? entry.filename
          : '$relative/${entry.filename}';
      if (entry.attr.isDirectory) {
        await walk(child);
      } else {
        entries.add(_FileEntry(child, entry.attr.size ?? 0));
      }
    }
  }

  await walk('');
  return entries;
}

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
  } catch (_) {}
}

Future<void> _createRemoteDirsForEntries(
  SftpClient sftp,
  String root,
  List<_FileEntry> entries,
) async {
  final dirs = <String>{};
  for (final entry in entries) {
    final parts = entry.relativePath.split('/');
    for (var i = 1; i < parts.length; i++) {
      dirs.add(parts.sublist(0, i).join('/'));
    }
  }
  final sorted = dirs.toList()
    ..sort((a, b) => a.split('/').length.compareTo(b.split('/').length));
  await _ensureRemoteDir(sftp, root);
  for (final dir in sorted) {
    await _ensureRemoteDir(sftp, '$root/$dir');
  }
}

Future<void> _sendProgress(
  SftpTransferParams params,
  _TransferTracker tracker,
  int current,
  int total,
) async {
  if (total <= 0) return;
  final (speed, shouldEmit) = tracker.record(current);
  if (shouldEmit) {
    params.sendPort.send(
      FileProgressData(
        currentBytes: current,
        totalBytes: total,
        bytesPerSecond: speed,
      ),
    );
  }
}

Future<SftpClient> _connect(SftpConnectParams params) async => SftpClient(
  await connectSftp(
    host: params.host,
    port: params.port,
    username: params.username,
    password: params.password,
    privateKeys: params.keyPems,
    keyPassphrases: params.keyPassphrases,
    expectedHostKey: params.hostKey,
    skipHostKeyVerification: params.skipHostKeyVerification,
  ),
);

Future<void> _copyRemoteToLocal(
  SftpClient sftp,
  String remotePath,
  String localPath,
  int fileSize,
  int total,
  int completed,
  _TransferTracker tracker,
  SftpTransferParams params,
) async {
  File(localPath).parent.createSync(recursive: true);
  final sink = File(localPath).openWrite();
  final remoteFile = await sftp.openRead(remotePath);
  var offset = 0;
  try {
    while (offset < fileSize) {
      final chunk = await remoteFile.readChunk(_kChunkSize);
      if (chunk.isEmpty) break;
      sink.add(chunk);
      offset += chunk.length;
      await _sendProgress(params, tracker, completed + offset, total);
    }
  } finally {
    await sink.close();
  }
}

Future<void> _copyLocalToRemote(
  SftpClient sftp,
  String localPath,
  String remotePath,
  int fileSize,
  int total,
  int completed,
  _TransferTracker tracker,
  SftpTransferParams params,
) async {
  final file = File(localPath).openSync();
  final remoteFile = await sftp.openWrite(remotePath, truncate: true);
  var offset = 0;
  try {
    if (fileSize == 0) {
      return;
    }
    while (offset < fileSize) {
      final chunk = file.readSync(_kChunkSize);
      if (chunk.isEmpty) break;
      await remoteFile.writeChunk(chunk);
      offset += chunk.length;
      await _sendProgress(params, tracker, completed + offset, total);
    }
  } finally {
    file.closeSync();
  }
}

Future<void> sftpTransferIsolate(SftpTransferParams p) async {
  final tracker = _TransferTracker();
  try {
    await RustLib.init();
    if (p.source != null && p.destination == null) {
      final sftp = await _connect(p.source!);
      final stat = await sftp.stat(p.sourcePath);
      final entries = stat.isDirectory
          ? await _listRemoteFilesRecursive(sftp, p.sourcePath)
          : [_FileEntry('', stat.size ?? 0)];
      if (stat.isDirectory) {
        Directory(p.destinationPath).createSync(recursive: true);
      }
      final total = entries.fold<int>(0, (sum, entry) => sum + entry.size);
      var completed = 0;
      for (final entry in entries) {
        final source = entry.relativePath.isEmpty
            ? p.sourcePath
            : '${p.sourcePath}/${entry.relativePath}';
        final destination = entry.relativePath.isEmpty
            ? p.destinationPath
            : _localJoin(p.destinationPath, entry.relativePath);
        await _copyRemoteToLocal(
          sftp,
          source,
          destination,
          entry.size,
          total,
          completed,
          tracker,
          p,
        );
        completed += entry.size;
      }
    } else if (p.source == null && p.destination != null) {
      final sftp = await _connect(p.destination!);
      final isDirectory =
          FileSystemEntity.typeSync(p.sourcePath) ==
          FileSystemEntityType.directory;
      final entries = isDirectory
          ? await _listLocalFilesRecursive(p.sourcePath)
          : [_FileEntry('', await File(p.sourcePath).length())];
      if (isDirectory) {
        await _createRemoteDirsForEntries(sftp, p.destinationPath, entries);
      }
      final total = entries.fold<int>(0, (sum, entry) => sum + entry.size);
      var completed = 0;
      for (final entry in entries) {
        final source = entry.relativePath.isEmpty
            ? p.sourcePath
            : _localJoin(p.sourcePath, entry.relativePath);
        final destination = entry.relativePath.isEmpty
            ? p.destinationPath
            : '${p.destinationPath}/${entry.relativePath}';
        await _copyLocalToRemote(
          sftp,
          source,
          destination,
          entry.size,
          total,
          completed,
          tracker,
          p,
        );
        completed += entry.size;
      }
    } else if (p.source != null && p.destination != null) {
      final sourceSftp = await _connect(p.source!);
      final destinationSftp = await _connect(p.destination!);
      final sourceStat = await sourceSftp.stat(p.sourcePath);
      if (p.source!.hostKey != null &&
          listEquals(p.source!.hostKey, p.destination!.hostKey)) {
        await sourceSftp.rename(p.sourcePath, p.destinationPath);
      } else {
        final entries = sourceStat.isDirectory
            ? await _listRemoteFilesRecursive(sourceSftp, p.sourcePath)
            : [_FileEntry('', sourceStat.size ?? 0)];
        if (sourceStat.isDirectory) {
          await _createRemoteDirsForEntries(
            destinationSftp,
            p.destinationPath,
            entries,
          );
        }
        final total = entries.fold<int>(0, (sum, entry) => sum + entry.size);
        var completed = 0;
        for (final entry in entries) {
          final source = entry.relativePath.isEmpty
              ? p.sourcePath
              : '${p.sourcePath}/${entry.relativePath}';
          final destination = entry.relativePath.isEmpty
              ? p.destinationPath
              : '${p.destinationPath}/${entry.relativePath}';
          final sourceFile = await sourceSftp.openRead(source);
          final destinationFile = await destinationSftp.openWrite(
            destination,
            truncate: true,
          );
          var offset = 0;
          while (offset < entry.size) {
            final chunk = await sourceFile.readChunk(_kChunkSize);
            if (chunk.isEmpty) break;
            await destinationFile.writeChunk(chunk);
            await _sendProgress(
              p,
              tracker,
              completed + offset + chunk.length,
              total,
            );
            offset += chunk.length;
          }
          completed += entry.size;
        }
      }
    } else {
      throw StateError('Both source and destination cannot be local.');
    }
    p.sendPort.send(const FileProgressData.completed());
  } catch (error) {
    p.sendPort.send(FileProgressData.error(error.toString()));
  }
}
