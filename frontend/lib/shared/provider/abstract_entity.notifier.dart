import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import 'abstract_entity.state.dart';

abstract class AbstractEntityNotifier<E, S>
    extends Notifier<AbstractEntityState<E>> {
  Logger get _log => Logger('Notifier[$E]');
  StreamSubscription<List<E>>? _sub;

  @override
  AbstractEntityState<E> build() {
    _sub = entityStream.listen((e) {
      _log.finest('Received ${e.length} entities');
      state = state.copyWith(entities: e);
    });

    ref.onDispose(() => _sub?.cancel());
    return buildInitialState();
  }

  AbstractEntityState<E> buildInitialState();
  Stream<List<E>> get entityStream;
}
