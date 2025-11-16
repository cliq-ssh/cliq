import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../data/database.dart';
import '../provider/session.provider.dart';

class ShellSessionPage extends StatefulHookConsumerWidget {
  final ShellSession session;

  const ShellSessionPage({super.key, required this.session});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShellSessionPageState();
}

class _ShellSessionPageState extends ConsumerState<ShellSessionPage>
    with AutomaticKeepAliveClientMixin {
  ShellSession get session => widget.session;
  SSHClient? get sshClient => session.sshClient;
  SSHSession? get sshSession => session.sshSession;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final typography = context.theme.typography;

    buildConnecting() {
      return [
        FCircularProgress(),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Connecting to '),
              TextSpan(
                text: widget.session.connection.address,
                style: typography.xl.copyWith(fontWeight: .bold),
              ),
            ],
          ),
          style: typography.xl,
        ),
      ];
    }

    buildError() {
      return [
        Icon(LucideIcons.plugZap, size: 36),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Failed to connect to '),
              TextSpan(
                text: '${widget.session.connection.address}:',
                style: typography.xl.copyWith(fontWeight: .bold),
              ),
            ],
          ),
          style: typography.xl,
        ),
        if (widget.session.connectionError != null)
          FCard(
            subtitle: Text(
              widget.session.connectionError!,
              style: typography.base,
              textAlign: TextAlign.center,
            ),
          ),
        FButton(onPress: () {}, child: Text('Retry')),
      ];
    }

    useEffect(() {
      Future<void> openSsh(ConnectionFull connection) async {
        final client = await ref
            .read(sessionProvider.notifier)
            .createSSHClient(connection);

        await ref
            .read(sessionProvider.notifier)
            .spawnShell(widget.session.id, client);
        // TODO: add listeners for terminal data, errors, etc.
      }

      CliqDatabase.connectionService
          .findConnectionFullById(widget.session.connection.id)
          .then((connection) {
            if (connection != null) openSsh(connection);
          });
      return () => widget.session.dispose();
    }, []);

    return FScaffold(
      child: CliqGridContainer(
        alignment: .center,
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                sizes: {.sm: 8},
                child: Column(
                  spacing: 32,
                  children: [
                    if (session.connectionError != null) ...buildError(),
                    if (session.isLikelyLoading) ...buildConnecting(),
                    if (widget.session.isConnected)
                      Text(
                        'Connected to ${widget.session.connection.address}, ${sshClient?.remoteVersion ?? '<version>'}',
                        style: typography.xl,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
