import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:dartssh2/dartssh2.dart';

/// Everything a worker needs to open an SSH connection.
class const SshConnectParams({
  required final String host,
  required final int port,
  required final String username,
  final String? password,
  final List<(String pem, String? passphrase)> keys = const [],
  final bool skipHostKeyVerification = false,
});

class const WorkerInit(final SendPort events, final SshConnectParams connect);

abstract class const WorkerCommand();

/// The main isolate's answer to a [HostKeyRequestEvent].
class const HostKeyReplyCommand(final int id, final bool accepted)
    extends WorkerCommand;

abstract class const WorkerEvent();

/// Send by the worker when it is ready to receive commands.
/// The worker is connected, authenticated and the shell is open
class const ReadyEvent() extends WorkerEvent;

/// Sent by the worker when it is done.
/// [error] is null for a clean exit
class const ClosedEvent(final String? error) extends WorkerEvent;

/// The worker needs the main isolate to verify a host key
class const HostKeyRequestEvent(
  final int id,
  final String algorithm,
  final Uint8List fingerprint,
) extends WorkerEvent;

/// Base class for everything that runs inside a worker isolate.
/// Handles connecting, host key round trips and closing
abstract class WorkerBase<I extends WorkerInit>(final I init) {
  SSHClient? client;

  final _commands = ReceivePort();

  /// Maps host key request IDs to completers that will be completed when the main isolate responds.
  final _hostKeyWaiters = <int, Completer<bool>>{};
  var _nextHostKeyId = 0;

  /// Whether the worker has been closed
  var _closed = false;

  Future<void> onConnected(SSHClient client);
  void onCommand(WorkerCommand command);
  void onClose() {}

  /// Sends an event to the main isolate
  void emit(WorkerEvent event) {
    init.events.send(event);
  }

  Future<void> run() async {
    // tell the main isolate where to send commands
    init.events.send(_commands.sendPort);
    _commands.listen((m) {
      final cmd = m as WorkerCommand;
      if (cmd is HostKeyReplyCommand) {
        _hostKeyWaiters.remove(cmd.id)?.complete(cmd.accepted);
      } else {
        onCommand(cmd);
      }
    });

    try {
      final c = client = await _openSshClient(
        init.connect,
        onVerifyHostKey: _verifyHostKey,
      );
      unawaited(
        c.done.then(
          (_) => close('Connection closed'),
          onError: (Object e) => close('$e'),
        ),
      );
      await c.authenticated;
      await onConnected(c);
      emit(const ReadyEvent());
    } catch (e) {
      close('$e');
    }
  }

  /// Closes the connection and tells the main isolate via a [ClosedEvent].
  void close([String? error]) {
    if (_closed) return;
    _closed = true;
    onClose();
    emit(ClosedEvent(error));
    for (final w in _hostKeyWaiters.values) {
      w.complete(false);
    }
    client?.close();
    _commands.close();
  }

  Future<SSHClient> _openSshClient(
    SshConnectParams p, {
    FutureOr<bool> Function(String algorithm, Uint8List fingerprint)?
    onVerifyHostKey,
  }) async {
    final socket = await SSHSocket.connect(
      p.host,
      p.port,
      timeout: const Duration(seconds: 10),
    );
    return SSHClient(
      socket,
      username: p.username,
      ident: SessionNotifier.getSshIdent(),
      identities: [
        for (final (pem, passphrase) in p.keys)
          ...SSHKeyPair.fromPem(pem, passphrase),
      ],
      onPasswordRequest: p.password != null ? () => p.password! : null,
      onVerifyHostKey: onVerifyHostKey,
    );
  }

  /// Verifies the host key by asking the main isolate.
  /// Returns true if the host key is accepted, false otherwise.
  Future<bool> _verifyHostKey(String algorithm, Uint8List fingerprint) {
    if (init.connect.skipHostKeyVerification) {
      return .value(true);
    }
    final id = _nextHostKeyId++;
    // wait for the main isolate to respond
    final waiter = _hostKeyWaiters[id] = Completer<bool>();
    emit(HostKeyRequestEvent(id, algorithm, fingerprint));
    return waiter.future;
  }
}

/// Base class for the handles the main isolate holds.
/// Spawns the isolate, routes events and answers host key requests
abstract class WorkerHandle {
  /// Spawns the worker isolate
  Future<Isolate> spawn(SendPort events, SshConnectParams params);

  void onEvent(WorkerEvent event);
  void onDispose() {}

  final _events = ReceivePort();
  final _ready = Completer<bool>();
  SendPort? _commandPort;
  Isolate? _isolate;
  var _disposed = false;

  late Future<bool> Function(HostKeyRequestEvent) _onHostKey;
  late void Function(String? error) _onClosed;

  bool get isDisposed => _disposed;

  /// Spawns the worker and completes once it is connected.
  /// Returns false if it closed before that, in which case [onClosed] was already called.
  Future<bool> start(
    SshConnectParams params, {
    required Future<bool> Function(HostKeyRequestEvent) onHostKey,
    required void Function(String? error) onClosed,
  }) async {
    _onHostKey = onHostKey;
    _onClosed = onClosed;
    _events.listen(_onMessage);
    _isolate = await spawn(_events.sendPort, params);
    return _ready.future;
  }

  void send(WorkerCommand command) {
    if (!_disposed) _commandPort?.send(command);
  }

  /// Kills the worker. Its sockets are closed together with the isolate.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _events.close();
    _isolate?.kill(priority: Isolate.immediate);
    // don't leave start() hanging if we're disposed while connecting
    if (!_ready.isCompleted) _ready.complete(false);
    onDispose();
  }

  void _onMessage(dynamic m) {
    switch (m) {
      case final SendPort p:
        _commandPort = p;
      case null:
        _handleClosed('Worker stopped unexpectedly');
      case ReadyEvent _:
        if (!_ready.isCompleted) _ready.complete(true);
      case final ClosedEvent c:
        _handleClosed(c.error);
      case final HostKeyRequestEvent r:
        _onHostKey(r)
            .catchError((_) => false)
            .then((ok) => send(HostKeyReplyCommand(r.id, ok)));
      case final WorkerEvent e:
        onEvent(e);
    }
  }

  void _handleClosed(String? error) {
    if (_disposed) return;
    _onClosed(error);
    dispose();
  }
}
