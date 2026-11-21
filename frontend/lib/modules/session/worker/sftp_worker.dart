import 'dart:async';
import 'dart:isolate';

import 'package:cliq/modules/session/worker/worker_core.dart';
import 'package:dartssh2/dartssh2.dart';

/// A base class for SFTP operations that can be executed in a worker isolate.
abstract class const SftpOp(final String path) {
  Future<Object?> run(SftpClient sftp);
}

/// See [SftpClient.listdir]
class const ListDirOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.listdir(path);
}

/// See [SftpClient.stat]
class const StatOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.stat(path);
}

/// See [SftpClient.absolute]
class const AbsoluteOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.absolute(path);
}

/// See [SftpClient.mkdir]
class const MkdirOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.mkdir(path);
}

/// See [SftpClient.rename]
class const RenameOp(super.path, final String to) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.rename(path, to);
}

/// See [SftpClient.remove]
class const RemoveOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.remove(path);
}

/// See [SftpClient.rmdir]
class const RmdirOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) => s.rmdir(path);
}

/// Runs in one go inside the worker instead of one round trip per entry.
class const RemoveRecursiveOp(super.path) extends SftpOp {
  @override
  Future<Object?> run(SftpClient s) async {
    await _remove(s, path);
    return null;
  }

  Future<void> _remove(SftpClient s, String path) async {
    if ((await s.stat(path, followLink: false)).isDirectory) {
      for (final e in await s.listdir(path)) {
        if (e.filename == '.' || e.filename == '..') continue;
        await _remove(s, '$path/${e.filename}');
      }
      await s.rmdir(path);
    } else {
      await s.remove(path);
    }
  }
}

class const SftpRequestCommand(final int id, final SftpOp operation)
    extends WorkerCommand;

/// Either [result] or [error] is set. [statusCode] is set for status errors
class const SftpResponseEvent(
  final int id, {
  final Object? result,
  final String? error,
  final int? statusCode,
}) extends WorkerEvent;

Future<void> sftpWorkerMain(WorkerInit init) => SftpWorker(init).run();

class SftpWorker(super.init) extends WorkerBase<WorkerInit> {
  SftpClient? _sftp;

  @override
  Future<void> onConnected(SSHClient client) async =>
      _sftp = await client.sftp();

  @override
  void onCommand(WorkerCommand command) {
    if (command is SftpRequestCommand) _run(command);
  }

  Future<void> _run(SftpRequestCommand r) async {
    try {
      emit(SftpResponseEvent(r.id, result: await r.operation.run(_sftp!)));
    } on SftpStatusError catch (e) {
      emit(SftpResponseEvent(r.id, error: e.message, statusCode: e.code));
    } catch (e) {
      emit(SftpResponseEvent(r.id, error: '$e'));
    }
  }
}

/// Mirrors the parts of [SftpClient] the UI uses, so the page code barely changes.
class SftpWorkerHandle extends WorkerHandle {
  final Map<int, Completer<Object?>> _pending = {};
  int _nextId = 0;

  @override
  Future<Isolate> spawn(SendPort events, SshConnectParams params) {
    return Isolate.spawn(
      sftpWorkerMain,
      WorkerInit(events, params),
      onExit: events,
    );
  }

  @override
  void onEvent(WorkerEvent event) {
    if (event is! SftpResponseEvent) return;
    final c = _pending.remove(event.id);
    if (c == null) return;
    if (event.error == null) {
      c.complete(event.result);
    } else if (event.statusCode != null) {
      c.completeError(SftpStatusError(event.statusCode!, event.error!));
    } else {
      c.completeError(Exception(event.error));
    }
  }

  Future<T> _request<T>(SftpOp op) {
    if (isDisposed) return Future.error(StateError('SFTP session closed'));
    final completer = Completer<Object?>();

    final id = _nextId++;
    _pending[id] = completer;
    send(SftpRequestCommand(id, op));
    return completer.future.then((v) => v as T);
  }

  Future<List<SftpName>> listdir(String path) async =>
      .from(await _request<List<dynamic>>(ListDirOp(path)));
  Future<SftpFileAttrs> stat(String path) => _request(StatOp(path));
  Future<String> absolute(String path) => _request(AbsoluteOp(path));
  Future<void> mkdir(String path) => _request<void>(MkdirOp(path));
  Future<void> rename(String from, String to) =>
      _request<void>(RenameOp(from, to));
  Future<void> remove(String path) => _request<void>(RemoveOp(path));
  Future<void> rmdir(String path) => _request<void>(RmdirOp(path));
  Future<void> removeRecursive(String path) =>
      _request<void>(RemoveRecursiveOp(path));

  @override
  void onDispose() {
    for (final c in _pending.values) {
      c.completeError(StateError('SFTP session closed'));
    }
    _pending.clear();
  }
}
