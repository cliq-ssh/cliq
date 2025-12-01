import 'dart:typed_data';

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
import 'package:cliq_term/cliq_term.dart';

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
  late final TerminalController _terminalController;

  ShellSession get session => widget.session;
  SSHClient? get sshClient => session.sshClient;
  SSHSession? get sshSession => session.sshSession;

  @override
  void initState() {
    super.initState();
    // TODO: listen for onTitleChange and update tab title
    _terminalController = TerminalController(
      rows: 20,
      cols: 80,
      onResize: (rows, cols) {
        sshSession?.resizeTerminal(cols, rows);
        showFToast(
          context: context,
          alignment: FToastAlignment.topCenter,
          title: Text('$cols x $rows'),
          duration: Duration(milliseconds: 500),
        );
      },
    );
  }

  @override
  void dispose() {
    _terminalController.dispose();
    super.dispose();
  }

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

        final shell = await ref
            .read(sessionProvider.notifier)
            .spawnShell(widget.session.id, client);

        _terminalController.onInput = (s) {
          if (sshSession != null) {
            sshSession!.stdin.add(Uint8List.fromList(s.codeUnits));
          }
        };

        shell?.stdout.listen((data) {
          _terminalController.feed(String.fromCharCodes(data));
        });

        shell?.stderr.listen((data) {
          _terminalController.feed(String.fromCharCodes(data));
        });
      }

      CliqDatabase.connectionService
          .findConnectionFullById(widget.session.connection.id)
          .then((connection) {
            if (connection != null) openSsh(connection);
          });
      return () => widget.session.dispose();
    }, []);

    if (widget.session.isConnected) {
      // TODO: load from config
      final theme = TerminalColorThemes.darcula;

      return SizedBox.expand(
        child: Container(
          color: theme.backgroundColor,
          padding: const .all(8),
          child: TerminalView(
              controller: _terminalController,
              typography: TerminalTypography(
                fontFamily: 'SourceCodePro',
                fontSize: 16,
              ),
              colors: theme,
          ),
        ),
      );
    }

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
