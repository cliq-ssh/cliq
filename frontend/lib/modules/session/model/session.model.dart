import 'package:cliq/modules/connections/extension/connection.extension.dart';
import 'package:dartssh2/dartssh2.dart';

import '../../../shared/data/sqlite/database.dart';

enum ShellSessionConnectionState { disconnected, connecting, connected }

class ShellSession {
  final int id;
  final Connection connection;
  final ShellSessionConnectionState state;
  final SSHClient? sshClient;
  final SSHSession? sshSession;

  const ShellSession({
    required this.id,
    required this.connection,
    this.state = .disconnected,
    this.sshClient,
    this.sshSession,
  });

  String get effectiveName => connection.effectiveName;

  ShellSession copyWith({
    ShellSessionConnectionState? state,
    SSHClient? sshClient,
    SSHSession? sshSession,
  }) {
    return ShellSession(
      id: id,
      connection: connection,
      state: state ?? this.state,
      sshClient: sshClient ?? this.sshClient,
      sshSession: sshSession ?? this.sshSession,
    );
  }
}
