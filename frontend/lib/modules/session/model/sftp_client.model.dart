import 'dart:typed_data';

import 'package:cliq/src/rust/ssh/ssh_client.dart' as rust;

enum SftpFileType { directory, regularFile, symbolicLink, other }

class SftpFileAttr {
  final int? size;
  final int mode;
  final int? modifyTime;
  final int? accessTime;

  const new({
    required this.size,
    required this.mode,
    required this.modifyTime,
    required this.accessTime,
  });

  bool get isDirectory => mode & 0xF000 == 0x4000;
  bool get isFile => mode & 0xF000 == 0x8000;
  bool get isSymbolicLink => mode & 0xF000 == 0xA000;
  SftpFileType get type => isDirectory
      ? .directory
      : isSymbolicLink
      ? .symbolicLink
      : isFile
      ? .regularFile
      : .other;
  bool get userRead => mode & 0x100 != 0;
  bool get userWrite => mode & 0x80 != 0;
  bool get userExecute => mode & 0x40 != 0;
  bool get groupRead => mode & 0x20 != 0;
  bool get groupWrite => mode & 0x10 != 0;
  bool get groupExecute => mode & 0x08 != 0;
  bool get otherRead => mode & 0x04 != 0;
  bool get otherWrite => mode & 0x02 != 0;
  bool get otherExecute => mode & 0x01 != 0;
}

class SftpName {
  final String filename;
  final String longname;
  final SftpFileAttr attr;

  const new({
    required this.filename,
    required this.longname,
    required this.attr,
  });
}

SftpFileAttr _mapAttr(rust.SftpFileAttr attr) => SftpFileAttr(
  size: attr.size?.toInt(),
  mode: attr.mode,
  modifyTime: attr.modifyTime?.toInt(),
  accessTime: attr.accessTime?.toInt(),
);

class SftpClient {
  final rust.SftpConnection _connection;

  const new(this._connection);

  Future<List<SftpName>> listdir(String path) async =>
      (await _connection.listdir(path: path))
          .map(
            (entry) => SftpName(
              filename: entry.filename,
              longname: entry.longname,
              attr: _mapAttr(entry.attr),
            ),
          )
          .toList();

  Future<SftpFileAttr> stat(String path) async =>
      _mapAttr(await _connection.stat(path: path));

  Future<String> absolute(String path) => _connection.absolute(path: path);

  Future<void> mkdir(String path) => _connection.mkdir(path: path);

  Future<void> rename(String oldPath, String newPath) =>
      _connection.rename(oldPath: oldPath, newPath: newPath);

  Future<void> remove(String path) => _connection.remove(path: path);

  Future<void> rmdir(String path) => _connection.rmdir(path: path);

  Future<Uint8List> readChunk(String path, int offset, int maxBytes) =>
      _connection.readFileChunk(
        path: path,
        offset: BigInt.from(offset),
        maxBytes: maxBytes,
      );

  Future<void> writeChunk(
    String path,
    int offset,
    List<int> data, {
    bool truncate = false,
  }) => _connection.writeFileChunk(
    path: path,
    offset: BigInt.from(offset),
    data: data,
    truncate: truncate,
  );

  Future<SftpFileHandle> openRead(String path) async =>
      SftpFileHandle(await _connection.openRead(path: path));

  Future<SftpFileHandle> openWrite(
    String path, {
    bool truncate = false,
  }) async => SftpFileHandle(
    await _connection.openWrite(path: path, truncate: truncate),
  );
}

class SftpFileHandle {
  final rust.SftpFileHandle _handle;

  const new(this._handle);

  Future<Uint8List> readChunk(int maxBytes) =>
      _handle.readChunk(maxBytes: maxBytes);

  Future<void> writeChunk(List<int> data) => _handle.writeChunk(data: data);
}
