import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/model/sftp_client.model.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';
import 'package:cliq/src/rust/ssh/ssh_client.dart';
import 'package:cliq_term/cliq_term.dart';

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

  /// The SFTP client associated with this session, only set if connected and SFTP is initialized.
  final SftpClient? sftpClient;

  /// The Rust-backed SSH terminal connection, only set for terminal sessions.
  final SshConnection? rustConnection;

  /// The terminal controller associated with this session, only set if connected.
  final TerminalController? terminalController;

  final StreamSubscription? stdoutSub;
  final StreamSubscription? stderrSub;
  final StreamSubscription? rustOutputSub;

  /// An optional known host error state for this session.
  /// May indicate that the host is unknown or has a mismatched fingerprint.
  final KnownHostError? knownHostError;

  /// Whether to skip host key verification for this session.
  final bool skipHostKeyVerification;

  new({
    required this.id,
    required this.type,
    required this.connection,
    this.connectionError,
    this.connectedAt,
    this.sftpClient,
    this.rustConnection,
    this.terminalController,
    this.stdoutSub,
    this.stderrSub,
    this.rustOutputSub,
    this.knownHostError,
    this.skipHostKeyVerification = false,
  });

  new disconnected({
    required this.id,
    required this.type,
    required this.connection,
    this.skipHostKeyVerification = false,
  }) : connectionError = null,
       connectedAt = null,
       sftpClient = null,
       rustConnection = null,
       terminalController = null,
       stdoutSub = null,
       stderrSub = null,
       rustOutputSub = null,
       knownHostError = null;

  bool get isConnected => sftpClient != null || rustConnection != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;

  void dispose() {
    terminalController?.dispose();
    stdoutSub?.cancel();
    stderrSub?.cancel();
    rustOutputSub?.cancel();
  }

  ShellSession copyWith({
    String? connectionError,
    DateTime? connectedAt,
    SftpClient? sftpClient,
    SshConnection? rustConnection,
    TerminalController? terminalController,
    StreamSubscription? stdoutSub,
    StreamSubscription? stderrSub,
    StreamSubscription? rustOutputSub,
    KnownHostError? knownHostError,
  }) {
    return ShellSession(
      id: id,
      type: type,
      connection: connection,
      connectionError: connectionError ?? this.connectionError,
      connectedAt: connectedAt ?? this.connectedAt,
      sftpClient: sftpClient ?? this.sftpClient,
      rustConnection: rustConnection ?? this.rustConnection,
      terminalController: terminalController ?? this.terminalController,
      stdoutSub: stdoutSub ?? this.stdoutSub,
      stderrSub: stderrSub ?? this.stderrSub,
      rustOutputSub: rustOutputSub ?? this.rustOutputSub,
      knownHostError: knownHostError ?? this.knownHostError,
    );
  }
}
