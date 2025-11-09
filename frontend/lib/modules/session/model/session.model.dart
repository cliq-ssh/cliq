import 'package:cliq/shared/data/sqlite/connections/connection.extension.dart';
import 'package:dartssh2/dartssh2.dart';

import '../../../shared/data/sqlite/database.dart';

enum ShellSessionConnectionState { disconnected, connecting, connected }

class ShellSession {
  final int id;
  final ShellSessionConnectionState connectionState;
  final Connection connection;
  final SSHClient? client;
  final SSHSession? sshSession;

  const ShellSession({
    required this.id,
    required this.connection,
    this.connectionState = ShellSessionConnectionState.disconnected,
    this.client,
    this.sshSession,
  });

  String get effectiveName => connection.effectiveName;

  ShellSession copyWith({
    ShellSessionConnectionState? state,
    Connection? connection,
    SSHClient? client,
    SSHSession? sshSession,
  }) {
    return ShellSession(
      id: id,
      connectionState: state ?? this.connectionState,
      connection: connection ?? this.connection,
      client: client ?? this.client,
      sshSession: sshSession ?? this.sshSession,
    );
  }
}
