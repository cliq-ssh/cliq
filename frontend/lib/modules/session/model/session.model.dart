import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_pty_new/flutter_pty_new.dart';

import '../../settings/model/known_host_error.model.dart';

enum SessionType { ssh, sftp, local }

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

  /// The SSH client associated with this session, only set if connected.
  final SSHClient? client;

  /// The SFTP client associated with this session, only set if connected and SFTP is initialized.
  final SftpClient? sftpClient;

  /// The SSH session associated with this session, only set if connected.
  final SSHSession? sshSession;

  /// The pseudo-terminal (PTY) associated with this session, only set for [SessionType.local] sessions.
  final Pty? pty;

  /// The terminal controller associated with this session, only set if connected.
  final TerminalController? terminalController;

  final StreamSubscription? stdoutSub;
  final StreamSubscription? stderrSub;

  /// An optional known host error state for this session.
  /// May indicate that the host is unknown or has a mismatched fingerprint.
  final KnownHostError? knownHostError;

  /// Whether to skip host key verification for this session.
  final bool skipHostKeyVerification;

  ShellSession({
    required this.id,
    required this.type,
    required this.connection,
    this.connectionError,
    this.connectedAt,
    this.client,
    this.sftpClient,
    this.sshSession,
    this.pty,
    this.terminalController,
    this.stdoutSub,
    this.stderrSub,
    this.knownHostError,
    this.skipHostKeyVerification = false,
  });

  ShellSession.disconnected({
    required this.id,
    required this.type,
    required this.connection,
    this.skipHostKeyVerification = false,
  }) : connectionError = null,
       connectedAt = null,
       client = null,
       sftpClient = null,
       sshSession = null,
       pty = null,
       terminalController = null,
       stdoutSub = null,
       stderrSub = null,
       knownHostError = null;

  bool get isConnected =>
      (client != null && (sshSession != null || sftpClient != null)) ||
      pty != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;

  void dispose() {
    sshSession?.kill(SSHSignal.KILL);
    sshSession?.close();
    client?.close();
    sftpClient?.close();
    terminalController?.dispose();
    stdoutSub?.cancel();
    stderrSub?.cancel();
    pty?.kill();
  }

  ShellSession copyWith({
    String? connectionError,
    DateTime? connectedAt,
    SSHClient? client,
    SftpClient? sftpClient,
    SSHSession? sshSession,
    Pty? pty,
    TerminalController? terminalController,
    StreamSubscription? stdoutSub,
    StreamSubscription? stderrSub,
    KnownHostError? knownHostError,
  }) {
    return ShellSession(
      id: id,
      type: type,
      connection: connection,
      connectionError: connectionError ?? this.connectionError,
      connectedAt: connectedAt ?? this.connectedAt,
      client: client ?? this.client,
      sftpClient: sftpClient ?? this.sftpClient,
      sshSession: sshSession ?? this.sshSession,
      pty: pty ?? this.pty,
      terminalController: terminalController ?? this.terminalController,
      stdoutSub: stdoutSub ?? this.stdoutSub,
      stderrSub: stderrSub ?? this.stderrSub,
      knownHostError: knownHostError ?? this.knownHostError,
    );
  }
}
