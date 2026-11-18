import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Returns the [SshSession] with the given [sessionId] from the [sessionProvider].
/// Rebuilds the calling widget only when this session changes.
SshSession? useSshSession(WidgetRef ref, String? sessionId) {
  if (sessionId == null) return null;
  return ref.watch(
    sessionProvider.select(
      (state) => state.sessions.where((s) => s.id == sessionId).firstOrNull,
    ),
  );
}
