import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/worker/sftp_worker.dart';
import 'package:cliq/modules/session/worker/ssh_worker.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';
import 'package:flterm/flterm.dart';

enum SessionType { ssh, sftp }

class ShellSession {
  /// A unique identifier for this session, used for state management and UI tracking.
  final String id;

  final SessionType type;

  /// The connection details associated with this session, including host, port, username, and authentication method.
  final ConnectionFull connection;

  /// A potential error that occurred during the connection attempt.
  /// If this is non-null, the session is considered disconnected.
  final String? connectionError;

  /// The timestamp when the session was successfully connected.
  final DateTime? connectedAt;

  /// The terminal controller associated with this session, only set if connected.
  final TerminalController? terminalController;

  /// An optional known host error state for this session.
  /// May indicate that the host is unknown or has a mismatched fingerprint.
  final KnownHostError? knownHostError;

  /// Whether to skip host key verification for this session.
  final bool skipHostKeyVerification;

  SshWorkerHandle? ssh;
  SftpWorkerHandle? sftp;

  new({
    required this.id,
    required this.type,
    required this.connection,
    this.connectionError,
    this.connectedAt,
    this.terminalController,
    this.knownHostError,
    this.ssh,
    this.sftp,
    this.skipHostKeyVerification = false,
  });

  new disconnected({
    required this.id,
    required this.type,
    required this.connection,
    this.skipHostKeyVerification = false,
  }) : connectionError = null,
       connectedAt = null,
       terminalController = null,
       knownHostError = null;

  bool get isConnected => ssh != null || sftp != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;

  void dispose() {
    ssh?.dispose();
    sftp?.dispose();
    terminalController?.dispose();
  }

  ShellSession copyWith({
    String? connectionError,
    DateTime? connectedAt,
    TerminalController? terminalController,
    KnownHostError? knownHostError,
    SshWorkerHandle? ssh,
    SftpWorkerHandle? sftp,
  }) {
    return ShellSession(
      id: id,
      type: type,
      connection: connection,
      connectionError: connectionError ?? this.connectionError,
      connectedAt: connectedAt ?? this.connectedAt,
      terminalController: terminalController ?? this.terminalController,
      knownHostError: knownHostError ?? this.knownHostError,
      ssh: ssh ?? this.ssh,
      sftp: sftp ?? this.sftp,
    );
  }
}
