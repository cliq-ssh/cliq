import 'dart:typed_data';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:dartssh2/dartssh2.dart';

class KnownHostError {
  final String host;
  final Uint8List hostKey;
  final String algorithm;
  final String sha256Fingerprint;
  // The known host entry that was found, if any.
  final KnownHostsCompanion? knownHost;

  const KnownHostError({
    required this.host,
    required this.hostKey,
    required this.algorithm,
    required this.sha256Fingerprint,
    this.knownHost,
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

  /// An optional known host error state for this session.
  /// May indicate that the host is unknown or has a mismatched fingerprint.
  final KnownHostError? knownHostError;

  /// Whether to skip host key verification for this session.
  final bool skipHostKeyVerification;

  const ShellSession({
    required this.id,
    required this.connection,
    this.connectionError,
    this.connectedAt,
    this.sshClient,
    this.sshSession,
    this.knownHostError,
    this.skipHostKeyVerification = false,
  });

  const ShellSession.disconnected({
    required this.id,
    required this.connection,
    this.skipHostKeyVerification = false,
  }) : connectionError = null,
       connectedAt = null,
       sshClient = null,
       sshSession = null,
       knownHostError = null;

  bool get isConnected => sshClient != null && sshSession != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;

  void dispose() {
    sshSession?.kill(SSHSignal.KILL);
    sshSession?.close();
    sshClient?.close();
  }

  ShellSession copyWith({
    String? connectionError,
    DateTime? connectedAt,
    SSHClient? sshClient,
    SSHSession? sshSession,
    KnownHostError? knownHostError,
  }) {
    return ShellSession(
      id: id,
      connection: connection,
      connectionError: connectionError ?? this.connectionError,
      connectedAt: connectedAt ?? this.connectedAt,
      sshClient: sshClient ?? this.sshClient,
      sshSession: sshSession ?? this.sshSession,
      knownHostError: knownHostError ?? this.knownHostError,
    );
  }
}
