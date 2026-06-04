import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/view/generic_session_page.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/navigation_shell.dart';
import '../provider/session.provider.dart';

class SftpSessionPage extends StatefulHookConsumerWidget {
  final String sessionId;

  const SftpSessionPage({super.key, required this.sessionId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SftpSessionPageState();
}

class _SftpSessionPageState extends ConsumerState<SftpSessionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final session = ref
        .watch(sessionProvider.notifier)
        .getSessionById(widget.sessionId)!;

    retrySession({bool skipHostKeyVerification = false}) {
      ref
          .read(sessionProvider.notifier)
          .resetSession(
            NavigationShell.of(context),
            session.id,
            skipHostKeyVerification: skipHostKeyVerification,
          );
    }

    // open SFTP connection when terminal controller is set
    useEffect(() {
      Future<void> openSftp(ConnectionFull connection) async {
        final client =
            session.client ??
            await ref
                .read(sessionProvider.notifier)
                .createSSHClient(session, connection);

        if (client == null || !mounted) {
          return;
        }

        await ref.read(sessionProvider.notifier).spawnSftp(session.id, client);
      }

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(session.connection.id);

      if (connectionFull != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          openSftp(connectionFull);
        });
      }

      return null;
    }, []);

    return GenericSessionPage(
      session: session,
      isConnected: session.isConnected,
      isLikelyLoading: session.isLikelyLoading,
      onRetry: retrySession,
      child: SizedBox.expand(child: Text('TODO: implement SFTP session page')),
    );
  }
}
