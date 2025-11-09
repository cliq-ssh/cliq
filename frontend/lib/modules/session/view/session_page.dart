import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/shared/data/sqlite/database.dart';
import 'package:cliq/shared/model/identity_full.model.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow, Breakpoint;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/data/sqlite/credentials/credential_type.dart';
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
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final connectionState = ref
        .watch(sessionProvider)
        .connectionStates[widget.session.id];
    final typography = context.theme.typography;

    final error = useState<String?>(null);
    final fullConnection = useState<ConnectionFull?>(null);

    final client = useState<SSHClient?>(null);
    final sshSession = useState<SSHSession?>(null);

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

    setConnectionState(ShellSessionConnectionState state) {
      ref.read(sessionProvider).connectionStates[widget.session.id] = state;
    }

    closeSession() {
      try {
        sshSession.value?.close();
      } catch (_) {}
      try {
        client.value?.close();
      } catch (_) {}
      sshSession.value = null;
      client.value = null;
    }

    useEffect(() {
      Future<void> openSsh() async {
        error.value = null;
        setConnectionState(ShellSessionConnectionState.connecting);

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
          if (cred.type == CredentialType.key) {
            try {
              if (SSHKeyPair.isEncryptedPem(cred.data)) {
                if (cred.passphrase == null) {
                  throw Exception('Key is encrypted but no passphrase provided');
                }
                keys = [
                  ...keys,
                  ...SSHKeyPair.fromPem(cred.data, cred.passphrase!)
                ];
              } else {
                keys = [...keys, ...SSHKeyPair.fromPem(cred.data)];
              }
            } catch (e, _) {}
          }
        }

        try {
          final socket = await SSHSocket.connect(con.address, con.port);

          final client = SSHClient(
            socket,
            username: effectiveUsername,
            identities: keys,
            onPasswordRequest: () {
              for (final cred in credentials) {
                if (cred.type == CredentialType.password) {
                  return cred.data;
                }
              }
              return null;
            },
          );

          final shell = await client.shell();
          await client.authenticated;
          setConnectionState(ShellSessionConnectionState.connected);
          print(client.remoteVersion);

          // TODO: add listeners for terminal data, errors, etc.
        } catch (e, _) {
          setConnectionState(ShellSessionConnectionState.disconnected);
          error.value = e.toString();

          closeSession();
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
                        passphrase: value.identityCredentialPassphrase
                      ),
                    ),
              credential: value.connectionCredentialId == null
                  ? null
                  : Credential(
                      id: value.connectionCredentialId!,
                      type: value.connectionCredentialType!,
                      data: value.connectionCredentialData!,
                      passphrase: value.connectionCredentialPassphrase
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

      return () => closeSession();
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
                    if (connectionState == ShellSessionConnectionState.connecting)
                      ...buildConnecting(),
                    if (connectionState == ShellSessionConnectionState.connected)
                      Text(
                        'Connected to ${widget.session.connection.address}, ${client.value?.remoteVersion ?? '<version>'}',
                        style: typography.xl,
                      ),
                    if (connectionState == ShellSessionConnectionState.disconnected)
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
