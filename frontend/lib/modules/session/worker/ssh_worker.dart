import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cliq/modules/session/worker/worker_core.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flterm/flterm.dart';
import 'package:flutter/scheduler.dart';

const _highWater = 512 * 1024; // pause reading above this many unacked bytes
const _lowWater = 128 * 1024; // resume below this
const _drainSlice =
    8 * 1024; // max bytes per terminal write, keeps one write short

class const InputCommand(final Uint8List data) extends WorkerCommand;

/// The terminal was resized, so the worker should resize the remote PTY.
class const ResizeCommand(final int cols, final int rows) extends WorkerCommand;

/// [bytes] of output were written to the terminal, so the worker may read more.
class const AckCommand(final int bytes) extends WorkerCommand;

/// The worker has output for the terminal.
/// [data] is a chunk of bytes, [length] is the number of bytes in this chunk.
class OutputEvent(final TransferableTypedData data, final int length)
    extends WorkerEvent;

class const SshWorkerInit(
  super.events,
  super.connect, {
  required final int cols,
  required final int rows,
}) extends WorkerInit;

Future<void> sshWorkerMain(SshWorkerInit init) => SshWorker(init).run();

class SshWorker(super.init) extends WorkerBase<SshWorkerInit> {
  final _subs = <StreamSubscription<Uint8List>>[];

  SSHSession? _shell;
  List<Uint8List> _chunks = [];
  int _chunksLength = 0;
  Timer? _flushTimer;
  int _inFlight = 0;
  bool _paused = false;

  @override
  Future<void> onConnected(SSHClient client) async {
    final shell = _shell = await client.shell(
      pty: SSHPtyConfig(width: init.cols, height: init.rows),
    );
    _subs
      ..add(shell.stdout.listen(_onData))
      ..add(shell.stderr.listen(_onData));
    // remote shell exited (e.g. exit), not an error
    unawaited(shell.done.then((_) => close()));
  }

  @override
  void onCommand(WorkerCommand command) {
    switch (command) {
      case final InputCommand c:
        _shell?.write(c.data);
      case final ResizeCommand c:
        _shell?.resizeTerminal(c.cols, c.rows);
      case final AckCommand c:
        _inFlight -= c.bytes;
        if (_inFlight < _lowWater) _setPaused(false);
    }
  }

  @override
  void onClose() {
    _flush();
    _flushTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
  }

  /// Collects chunks and flushes them every 8ms instead of sending each one.
  void _onData(Uint8List data) {
    _chunks.add(data);
    _chunksLength += data.length;
    _flushTimer ??= Timer(const Duration(milliseconds: 8), _flush);
  }

  /// Flushes the collected chunks to the main isolate, and pauses reading if too much is in flight.
  void _flush() {
    _flushTimer = null;
    if (_chunks.isEmpty) return;
    emit(OutputEvent(.fromList(_chunks), _chunksLength));
    _inFlight += _chunksLength;
    _chunks = [];
    _chunksLength = 0;
    if (_inFlight > _highWater) _setPaused(true);
  }

  void _setPaused(bool value) {
    if (value == _paused) return;
    _paused = value;
    for (final s in _subs) {
      value ? s.pause() : s.resume();
    }
  }
}

class SshWorkerHandle(final TerminalController controller)
    extends WorkerHandle {
  final _queue = Queue<Uint8List>();

  int _head = 0; // read offset into _queue.first
  bool _drainScheduled = false;
  Timer? _resizeTimer;

  @override
  Future<Isolate> spawn(SendPort events, SshConnectParams params) {
    return Isolate.spawn(
      sshWorkerMain,
      SshWorkerInit(
        events,
        params,
        cols: controller.config.cols,
        rows: controller.config.rows,
      ),
      onExit: events,
    );
  }

  @override
  void onEvent(WorkerEvent event) {
    if (event is! OutputEvent) return;
    _queue.add(event.data.materialize().asUint8List());
    _scheduleDrain();
  }

  /// Writes queued output to the terminal once per frame, with a time budget,
  /// so a flood slows the terminal down instead of freezing the UI.
  void _scheduleDrain() {
    if (_drainScheduled || isDisposed) return;
    _drainScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _drainScheduled = false;
      _drain();
    });
  }

  /// Drains queued output to the terminal, with a time budget of 4ms per frame.
  /// If the queue is still not empty, schedules another drain for the next frame.
  void _drain() {
    if (isDisposed) return;
    final sw = Stopwatch()..start();
    var consumed = 0;

    while (_queue.isNotEmpty && sw.elapsedMicroseconds < 4000) {
      final chunk = _queue.first;
      final end = min(_head + _drainSlice, chunk.length);
      controller.write(.sublistView(chunk, _head, end));
      consumed += end - _head;
      if (end == chunk.length) {
        _queue.removeFirst();
        _head = 0;
      } else {
        _head = end;
      }
    }

    if (consumed > 0) send(AckCommand(consumed));
    if (_queue.isNotEmpty) _scheduleDrain();
  }

  void write(List<int> input) {
    send(InputCommand(input is Uint8List ? input : Uint8List.fromList(input)));
  }

  void resize(int cols, int rows) {
    _resizeTimer?.cancel();
    // small debounce to avoid flooding events
    _resizeTimer = Timer(
      const Duration(milliseconds: 100),
      () => send(ResizeCommand(cols, rows)),
    );
  }

  @override
  void onDispose() {
    var offset = _head;
    for (final chunk in _queue) {
      controller.write(.sublistView(chunk, offset));
      offset = 0;
    }
    _queue.clear();
    _resizeTimer?.cancel();
  }
}
