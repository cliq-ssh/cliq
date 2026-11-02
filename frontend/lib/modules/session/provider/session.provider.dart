import 'dart:async';
import 'dart:ui';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/credentials/data/credential.service.dart';
import 'package:cliq/modules/credentials/provider/credential_service.provider.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/model/session.state.dart';
import 'package:cliq/modules/session/worker/sftp_worker.dart';
import 'package:cliq/modules/session/worker/ssh_worker.dart';
import 'package:cliq/modules/session/worker/worker_core.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';
import 'package:cliq/modules/settings/provider/known_host_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/build_metadata.dart';
import 'package:flterm/flterm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/v7.dart';

final sessionProvider = NotifierProvider(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  static const UuidV7 uuid = UuidV7();

  @override
  SessionState build() => const SessionState.initial();

  static String getSshIdent() => 'SSH-2.0-cliq_${BuildMetadata.version}';

  /// Connects a new SSH session for the given [connection] and adds it to the state
  Future<SshWorkerHandle?> connectSsh(
    ShellSession session,
    ConnectionFull connection,
    TerminalController terminal, {
    required VoidCallback onExit,
  }) async {
    final worker = SshWorkerHandle(terminal);
    if (!await _startWorker(worker, session, connection, onExit: onExit)) {
      return null;
    }

    _modify(
      session.id,
      (s) => s.copyWith(
        connectedAt: .now(),
        ssh: worker,
        terminalController: terminal,
      ),
    );
    return worker;
  }

  /// Connects a new SFTP session for the given [connection] and adds it to the state
  Future<SftpWorkerHandle?> connectSftp(
    ShellSession session,
    ConnectionFull connection,
  ) async {
    final worker = SftpWorkerHandle();
    if (!await _startWorker(worker, session, connection)) return null;

    _modify(session.id, (s) => s.copyWith(connectedAt: .now(), sftp: worker));
    return worker;
  }

  /// Finds the [ShellSession] with the given [sessionId] across all tabs, or null if not found.
  ShellSession? findById(String sessionId) {
    return state.sessions.where((s) => s.id == sessionId).firstOrNull;
  }

  /// Renames the session to [customTitle]. If [customTitle] is null or empty the custom label will be
  /// cleared and UI will fall back to the default connection label.
  void rename(
    String sessionId,
    String? customTitle, {
    bool userChangedTitle = true,
  }) {
    // check if user changed title before, do nothing it they have
    if (!userChangedTitle && findById(sessionId)?.userChangedTitle == true) {
      return;
    }

    _modify(
      sessionId,
      (s) => s.copyWith(title: customTitle, userChangedTitle: userChangedTitle),
    );
  }

  /// Accepts the host key for the given [sessionId] and [vaultId], updating the known hosts database accordingly.
  /// This should be called after the user has accepted the fingerprint presented in a [KnownHostError].
  Future<void> acceptFingerprint(
    DbId vaultId,
    String sessionId,
    KnownHostError error,
  ) async {
    if (error.knownHost != null) {
      await ref
          .read(knownHostServiceProvider)
          .update(
            error.knownHost!.id.value,
            vaultId: vaultId,
            fingerprint: error.fingerprint,
            compareTo: error.knownHost,
          );
    }
    await ref
        .read(knownHostServiceProvider)
        .createKnownHost(
          vaultId: vaultId,
          host: error.host,
          fingerprint: error.fingerprint,
        );
  }

  /// Resets a session with the given [sessionId], disposing of any existing resources and clearing the connection state.
  /// Optionally, [skipHostKeyVerification] can be set to true to skip host key verification for the next connection attempt.
  void reset(String sessionId, {bool? skipHostKeyVerification}) {
    _modify(sessionId, (session) {
      session.dispose();
      return session.copyWith(
        connectedAt: null,
        terminalController: null,
        skipHostKeyVerification: skipHostKeyVerification,
      );
    });
  }

  /// Closes the session with the given [sessionId], disposing of any existing resources and setting the connection error state.
  void failAndDispose(String sessionId, String? error) {
    _modify(sessionId, (session) {
      session.dispose();
      return session.copyWith(
        connectionError: error,
        connectedAt: null,
        terminalController: null,
      );
    });
  }

  /// Removes the session with the given [sessionId] from the state, disposing of any existing resources.
  void remove(String sessionId) {
    _modify(sessionId, (session) {
      session.dispose();
      return session;
    });
    state = state.copyWith(
      sessions: state.sessions
          .where((s) => s.id != sessionId)
          .toList(growable: false),
    );
  }

  /// Verifies the host key for the given [session] and [connection] against the provided [request].
  /// If the host key is not known or does not match, the session will be updated with a [KnownHostError] and the user
  /// will need to accept the fingerprint before retrying.
  Future<bool> _verifyHostKey(
    ShellSession session,
    ConnectionFull connection,
    HostKeyRequestEvent request,
  ) async {
    final (knownHost, isKeyMatch) = await ref
        .read(knownHostServiceProvider)
        .isHostKnown(connection.addressAndPort, request.fingerprint);

    if (knownHost != null && isKeyMatch) return true;

    _modify(
      session.id,
      (s) => s.copyWith(
        knownHostError: KnownHostError(
          host: connection.addressAndPort,
          algorithm: request.algorithm,
          fingerprint: request.fingerprint,
          knownHost: knownHost,
        ),
      ),
    );

    // fail for now, the user can accept the key and retry
    return false;
  }

  /// Returns true if the worker is connected and ready
  Future<bool> _startWorker(
    WorkerHandle worker,
    ShellSession session,
    ConnectionFull connection, {
    VoidCallback? onExit,
  }) async {
    final SshConnectParams params;
    try {
      params = await _buildParams(session, connection);
    } catch (e) {
      failAndDispose(session.id, e.toString());
      return false;
    }

    final ok = await worker.start(
      params,
      onHostKey: (r) => _verifyHostKey(session, connection, r),
      // clean exit
      onClosed: (e) => e == null && onExit != null
          ? onExit()
          : failAndDispose(session.id, e),
    );
    if (!ok) return false; // onClosed already reported the error

    // the session was closed or reset while we were connecting
    if (findById(session.id) == null) {
      worker.dispose();
      return false;
    }
    return true;
  }

  /// Builds the plain-data params every worker connects with
  Future<SshConnectParams> _buildParams(
    ShellSession session,
    ConnectionFull connection,
  ) async {
    final ids = await ref
        .read(credentialServiceProvider)
        .findByIds(
          connection.identity?.credentialIds ?? connection.credentialIds,
        );
    final (password, keys) =
        await CredentialService.collectAuthenticationMethods(ids);

    return .new(
      host: connection.address,
      port: connection.port,
      username: connection.effectiveUsername!,
      password: password,
      keys: keys.map((k) => (k.toPem(), password)).toList(),
      skipHostKeyVerification: session.skipHostKeyVerification,
    );
  }

  /// Modifies the session with the given [sessionId] using the provided [modify] function,
  /// and updates the state accordingly.
  void _modify(String sessionId, ShellSession Function(ShellSession) modify) {
    final newSessions = List.of(state.sessions, growable: false)
        .map<ShellSession>((s) => s.id == sessionId ? modify(s) : s)
        .toList(growable: false);
    state = state.copyWith(sessions: newSessions);
  }
}
