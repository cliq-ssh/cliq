import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/shared/data/sqlite/database.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow, Breakpoint;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/sqlite/credentials/credential_type.dart';

class ShellSessionPage extends StatefulHookConsumerWidget {
  final ShellSession session;

  const ShellSessionPage({super.key, required this.session});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShellSessionPageState();
}

class _ShellSessionPageState extends ConsumerState<ShellSessionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final connectionState = useState(widget.session.connectionState);
    final typography = context.theme.typography;

    final error = useState<String?>(null);

    buildConnecting() {
      return [
        FCircularProgress(),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Connecting to '),
              TextSpan(
                text: widget.session.connection.address,
                style: typography.xl.copyWith(fontWeight: FontWeight.bold),
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
                style: typography.xl.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          style: typography.xl,
        ),
        if (error.value != null)
          FCard(
            subtitle: Text(
              error.value!,
              style: typography.base,
              textAlign: TextAlign.center,
            ),
          ),
        FButton(onPress: () {}, child: Text('Retry')),
      ];
    }

    useEffect(() {
      Future<void> openSsh() async {
        error.value = null;
        connectionState.value = ShellSessionConnectionState.connecting;

        final host = widget.session.connection.address;
        final port = widget.session.connection.port;
        final username = widget.session.connection.username;

        // TODO: implement identities, clean this up

        final credentials = await CliqDatabase.connectionService
            .findCredentialsByConnectionId(widget.session.connection);

        try {
          final socket = await SSHSocket.connect(host, port);

          final client = SSHClient(
            socket,
            username: username!,
            onPasswordRequest: () {
              for (final cred in credentials) {
                if (cred.type == CredentialType.password) {
                  return cred.data;
                }
              }
              return null;
            },
          );

          widget.session.copyWith(client: client);
          final shell = await client.shell();
          widget.session.copyWith(sshSession: shell);

          connectionState.value = ShellSessionConnectionState.connected;
          widget.session.copyWith(state: ShellSessionConnectionState.connected);
        } catch (e, _) {
          error.value = (e as SSHAuthFailError).message;
          connectionState.value = ShellSessionConnectionState.disconnected;
          widget.session.copyWith(
            state: ShellSessionConnectionState.disconnected,
          );

          try {
            widget.session.sshSession?.close();
          } catch (_) {}
          try {
            widget.session.client?.close();
          } catch (_) {}
          widget.session.copyWith(sshSession: null);
          widget.session.copyWith(client: null);
        }
      }

      openSsh();

      return () {
        try {
          widget.session.sshSession?.close();
        } catch (_) {}
        try {
          widget.session.client?.close();
        } catch (_) {}
      };
    }, []);

    return FScaffold(
      child: CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                sizes: {Breakpoint.sm: 8},
                child: Column(
                  spacing: 32,
                  children: [
                    if (connectionState.value ==
                        ShellSessionConnectionState.connecting)
                      ...buildConnecting(),
                    if (connectionState.value ==
                        ShellSessionConnectionState.disconnected)
                      ...buildError(),
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
