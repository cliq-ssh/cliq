import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/worker/sftp_worker.dart';
import 'package:cliq/modules/session/worker/ssh_worker.dart';
import 'package:cliq/modules/session/worker/worker_core.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flterm/flterm.dart';

enum SessionType { ssh, sftp }

/// A model representing a shell session, which can be either an SSH or SFTP session.
/// This class encapsulates the connection details, terminal controller, and state of the session.
class ShellSession({
  /// A unique identifier for this session, used for state management and UI tracking.
  required final String id,
  required final SessionType type,

  /// The connection details associated with this session, including host, port, username, and authentication method.
  required final ConnectionFull connection,

  /// A potential error that occurred during the connection attempt.
  /// If this is non-null, the session is considered disconnected.
  final String? connectionError,

  /// The timestamp when the session was successfully connected.
  final DateTime? connectedAt,

  /// The terminal controller associated with this session, only set if connected.
  final TerminalController? terminalController,

  /// An optional known host error state for this session.
  /// May indicate that the host is unknown or has a mismatched fingerprint.
  final KnownHostError? knownHostError,

  /// Whether to skip host key verification for this session.
  final bool skipHostKeyVerification = false,

  /// The sessions's title, which may be used in the UI to display a custom label for the session.
  /// If [userChangedTitle] is true, this is a custom title set by the user which should not be changed.
  final String? title,

  /// Whether the user has manually changed the session's title.
  /// If true, the UI will not override the title with a default label.
  final bool userChangedTitle = false,

  var SshWorkerHandle? _ssh,
  var SftpWorkerHandle? _sftp,
}) {
  SshWorkerHandle? get ssh => _ssh;
  SftpWorkerHandle? get sftp => _sftp;

  bool get isConnected => _ssh != null || _sftp != null;

  /// Whether the session is likely in the process of connecting, since it is not connected and has no error.
  bool get isLikelyLoading => !isConnected && connectionError == null;

  String getEffectiveTitle(BuildContext context) {
    if (userChangedTitle && title != null && title!.isNotEmpty) {
      return title!;
    }

    if (connectionError != null) {
      return 'session_error_title'.tr(context: context);
    }

    return connection.label;
  }

  /// Dispose of any resources associated with this session,
  /// including the SSH/SFTP handles and the terminal controller.
  void dispose() {
    _ssh?.dispose();
    _sftp?.dispose();
    _ssh = null;
    _sftp = null;

    terminalController?.dispose();
  }

  /// Sets the worker handle for this session, either SSH or SFTP.
  /// Throws a [StateError] if the handle type does not match the initial session [type].
  ShellSession setHandle(WorkerHandle handle) {
    if (_ssh != null || _sftp != null) {
      throw StateError(
        'Cannot set handle on a session that already has a handle',
      );
    }

    if (handle is SshWorkerHandle) {
      if (type != .ssh) {
        throw StateError('Cannot set SSH handle on a non-SSH session');
      }
      _ssh = handle;
    } else if (handle is SftpWorkerHandle) {
      if (type != .sftp) {
        throw StateError('Cannot set SFTP handle on a non-SFTP session');
      }
      _sftp = handle;
    }
    return this;
  }

  ShellSession copyWith({
    String? connectionError,
    DateTime? connectedAt,
    TerminalController? terminalController,
    KnownHostError? knownHostError,
    bool? skipHostKeyVerification,
    String? title,
    bool? userChangedTitle,
    SshWorkerHandle? ssh,
    SftpWorkerHandle? sftp,
  }) {
    return ShellSession(
      id: id,
      type: type,
      connection: connection,
      ssh: _ssh,
      sftp: _sftp,
      connectionError: connectionError ?? this.connectionError,
      connectedAt: connectedAt ?? this.connectedAt,
      terminalController: terminalController ?? this.terminalController,
      knownHostError: knownHostError ?? this.knownHostError,
      skipHostKeyVerification:
          skipHostKeyVerification ?? this.skipHostKeyVerification,
      title: title ?? this.title,
      userChangedTitle: userChangedTitle ?? this.userChangedTitle,
    );
  }
}
