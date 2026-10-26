import 'dart:collection';

import 'package:cliq_term/cliq_term.dart';

/// Registry for keeping track of all active [TerminalController] instances.
/// This is used for the devtools service to provide information about all active terminals.
class TerminalRegistry._() {
  static final instance = TerminalRegistry._();

  final _controllers = <String, TerminalController>{};

  UnmodifiableMapView<String, TerminalController> get controllers =>
      .new(_controllers);

  void register(String id, TerminalController controller) =>
      _controllers[id] = controller;
  void unregister(String id) => _controllers.remove(id);
}
