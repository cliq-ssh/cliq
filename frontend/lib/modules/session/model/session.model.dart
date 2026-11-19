import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/model/session_resources.model.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';

enum SessionType { ssh, sftp }

/// A model representing the status of a session.
sealed class const SessionStatus();

class const SessionConnecting() extends SessionStatus;
class const SessionNeedsHostTrust(final KnownHostError error)
    extends SessionStatus;
class const SessionFailed(final String message) extends SessionStatus;
class SessionConnected(
  final DateTime connectedAt,
  final SessionResources resources,
) extends SessionStatus;

/// A model representing a ssh session, which can be either SSH or SFTP.
/// This class encapsulates the connection details, terminal controller, and state of the session.
class const SshSession({
  /// A unique identifier for this session, used for state management and UI tracking.
  required final String id,
  required final SessionType type,

  /// The connection details associated with this session, including host, port, username, and authentication method.
  required final ConnectionFull connection,

  /// The sessions current status. Can either be of type [SessionConnecting], [SessionNeedsHostTrust], [SessionFailed], or [SessionConnected].
  final SessionStatus status = const SessionConnecting(),

  /// Whether to skip host key verification for this session.
  final bool skipHostKeyVerification = false,
}) {
  SessionResources? get resources => switch (status) {
    SessionConnected(:final resources) => resources,
    _ => null,
  };

  SshSession copyWith({SessionStatus? status, bool? skipHostKeyVerification}) {
    return SshSession(
      id: id,
      type: type,
      connection: connection,
      status: status ?? this.status,
      skipHostKeyVerification:
          skipHostKeyVerification ?? this.skipHostKeyVerification,
    );
  }
}
