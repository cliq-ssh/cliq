import 'package:cliq/modules/connections/extension/connection.extension.dart';

import '../../../shared/data/sqlite/database.dart';

enum ShellSessionConnectionState { disconnected, connecting, connected }

class ShellSession {
  final int id;
  final Connection connection;

  const ShellSession({required this.id, required this.connection});

  String get effectiveName => connection.effectiveName;

  ShellSession copyWith({Connection? connection}) {
    return ShellSession(id: id, connection: connection ?? this.connection);
  }
}
