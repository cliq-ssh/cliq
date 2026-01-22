import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:dartssh2/dartssh2.dart';

/// DTO for the state of a known host verification.
class KnownHostState {
  final bool isKnown;
  final bool isMatch;
  final String? host;
  final String? fingerprint;

  const KnownHostState({
    required this.host,
    required this.fingerprint,
    required this.isKnown,
    required this.isMatch,
  });
}

class ShellSession {
  final String id;
  final ConnectionFull connection;

  /// A potential error that occurred during the connection attempt.
  /// If this is non-null, the session is considered disconnected.
  final String? connectionError;

  /// The timestamp when the session was successfully connected.
  final DateTime? connectedAt;

  /// The SSH client associated with this session, only set if connected.
  final SSHClient? sshClient;

  /// The SSH session associated with this session, only set if connected.
  final SSHSession? sshSession;

  final KnownHostState? knownHostState;

  const ShellSession({
    required this.id,
    required this.connection,
    this.connectionError,
    this.connectedAt,
    this.sshClient,
    this.sshSession,
    this.knownHostState,
  });

  const ShellSession.disconnected({required this.id, required this.connection})
    : connectionError = null,
      connectedAt = null,
      sshClient = null,
      sshSession = null,
      knownHostState = null;

  bool get isConnected => sshClient != null && sshSession != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;

  void dispose() {
    sshSession?.kill(SSHSignal.KILL);
    sshSession?.close();
    sshClient?.close();
  }

  ShellSession copyWith({
    DateTime? connectedAt,
    SSHClient? sshClient,
    SSHSession? sshSession,
    KnownHostState? knownHostState,
  }) {
    return ShellSession(
      id: id,
      connection: connection,
      connectedAt: connectedAt ?? this.connectedAt,
      sshClient: sshClient ?? this.sshClient,
      sshSession: sshSession ?? this.sshSession,
      knownHostState: knownHostState ?? this.knownHostState,
    );
  }
}
