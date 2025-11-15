import 'package:cliq/modules/connections/extension/connection.extension.dart';
import 'package:dartssh2/dartssh2.dart';

import '../../../shared/data/sqlite/database.dart';

class ShellSession {
  final String id;
  final Connection connection;

  /// A potential error that occurred during the connection attempt.
  /// If this is non-null, the session is considered disconnected.
  final String? connectionError;

  /// The timestamp when the session was successfully connected.
  final DateTime? connectedAt;

  /// The SSH client associated with this session, only set if connected.
  final SSHClient? sshClient;

  /// The SSH session associated with this session, only set if connected.
  final SSHSession? sshSession;

  const ShellSession({
    required this.id,
    required this.connection,
    this.connectionError,
    this.connectedAt,
    this.sshClient,
    this.sshSession,
  });

  const ShellSession.disconnected({required this.id, required this.connection})
    : connectionError = null,
      connectedAt = null,
      sshClient = null,
      sshSession = null;

  bool get isConnected => sshClient != null && sshSession != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;
  String get effectiveName => connection.effectiveName;

  void dispose() {
    sshSession?.kill(SSHSignal.KILL);
    sshSession?.close();
    sshClient?.close();
  }

  ShellSession copyWith({
    DateTime? connectedAt,
    SSHClient? sshClient,
    SSHSession? sshSession,
  }) {
    return ShellSession(
      id: id,
      connection: connection,
      connectedAt: connectedAt ?? this.connectedAt,
      sshClient: sshClient ?? this.sshClient,
      sshSession: sshSession ?? this.sshSession,
    );
  }
}
