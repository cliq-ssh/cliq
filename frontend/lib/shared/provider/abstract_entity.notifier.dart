import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import 'abstract_entity.state.dart';

abstract class AbstractEntityNotifier<E, S extends AbstractEntityState<E, S>>
    extends Notifier<S> {
  Logger get _log => Logger('Notifier[$E]');

  final Completer<void> _initialized = Completer();
  Future<void> get initialized => _initialized.future;

  @override
  S build() {
    final sub = entityStream.listen((e) {
      if (!_initialized.isCompleted) _initialized.complete();
      _log.finest('Received ${e.length} entities');
      state = buildStateFromEntities(e);
    });

    ref.onDispose(sub.cancel);
    return buildInitialState();
  }

  S buildStateFromEntities(List<E> entities);
  S buildInitialState();
  Stream<List<E>> get entityStream;
}
