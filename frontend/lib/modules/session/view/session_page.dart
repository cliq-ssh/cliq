import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/shared/data/sqlite/database.dart';
import 'package:cliq/shared/model/identity_full.model.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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

  SSHClient? get sshClient => widget.session.sshClient;
  SSHSession? get sshSession => widget.session.sshSession;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final typography = context.theme.typography;
    final error = useState<String?>(null);
    final fullConnection = useState<ConnectionFull?>(null);

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
        ref
            .read(sessionProvider.notifier)
            .setSessionState(widget.session.id, .connecting);

        final con = fullConnection.value!;

        final shouldUseIdentity = con.identity != null;

        // determine effective username
        final effectiveUsername = shouldUseIdentity
            ? con.identity!.username
            : con.username!;

        // collect possible credentials
        final credentials = <Credential>[
          ?con.credential,
          if (shouldUseIdentity) ?con.identity?.credential,
        ];

        List<SSHKeyPair> keys = [];
        for (final cred in credentials) {
          if (cred.type == .key) {
            try {
              if (SSHKeyPair.isEncryptedPem(cred.data)) {
                if (cred.passphrase == null) {
                  throw Exception(
                    'Key is encrypted but no passphrase provided',
                  );
                }
                keys = [
                  ...keys,
                  ...SSHKeyPair.fromPem(cred.data, cred.passphrase!),
                ];
              } else {
                keys = [...keys, ...SSHKeyPair.fromPem(cred.data)];
              }
            } catch (e, _) {}
          }
        }

        try {
          final socket = await SSHSocket.connect(con.address, con.port);

          final sshClient = SSHClient(
            socket,
            username: effectiveUsername,
            identities: keys,
            onPasswordRequest: () {
              for (final cred in credentials) {
                if (cred.type == .password) {
                  return cred.data;
                }
              }
              return null;
            },
          );

          final sshShell = await sshClient.shell();
          await sshClient.authenticated;
          ref.read(sessionProvider.notifier)
            ..setSessionSSHClient(widget.session.id, sshClient)
            ..setSessionSSHSession(widget.session.id, sshShell)
            ..setSessionState(widget.session.id, .connected);

          // TODO: add listeners for terminal data, errors, etc.
        } catch (e, _) {
          ref
              .read(sessionProvider.notifier)
              .setSessionState(widget.session.id, .disconnected);
          error.value = e.toString();

          widget.session.dispose();
        }
      }

      CliqDatabase.connectionsRepository.db
          .findFullConnectionById(widget.session.connection.id)
          .getSingleOrNull()
          .then((value) {
            // TODO: move mapping to service
            return ConnectionFull(
              id: value!.connectionId,
              address: value.address,
              port: value.port,
              identity: value.identityId == null
                  ? null
                  : IdentityFull(
                      id: value.identityId!,
                      username: value.identityUsername!,
                      credential: Credential(
                        id: value.identityCredentialId!,
                        type: value.identityCredentialType!,
                        data: value.identityCredentialData!,
                        passphrase: value.identityCredentialPassphrase,
                      ),
                    ),
              credential: value.connectionCredentialId == null
                  ? null
                  : Credential(
                      id: value.connectionCredentialId!,
                      type: value.connectionCredentialType!,
                      data: value.connectionCredentialData!,
                      passphrase: value.connectionCredentialPassphrase,
                    ),
              username: value.connectionUsername,
              label: value.label,
              icon: value.icon,
              color: value.color,
            );
          })
          .then((value) {
            fullConnection.value = value;
            openSsh();
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
                    if (widget.session.state == .connecting)
                      ...buildConnecting(),
                    if (widget.session.state == .connected)
                      Text(
                        'Connected to ${widget.session.connection.address}, ${sshClient?.remoteVersion ?? '<version>'}',
                        style: typography.xl,
                      ),
                    if (widget.session.state == .disconnected) ...buildError(),
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
