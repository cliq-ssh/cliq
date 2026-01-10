import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_term/cliq_term.dart';

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
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _terminalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final terminalController = useState<TerminalController?>(null);
    final typography = context.theme.typography;
    final size = MediaQuery.of(context).size;

    final terminalTypography = useStore(StoreKey.terminalTypography);
    final terminalTheme = ref.watch(terminalThemeProvider);

    getEffectiveTerminalTypography() =>
        widget.session.connection.terminalTypographyOverride ??
        terminalTypography.value!;

    getEffectiveTerminalTheme() =>
        widget.session.connection.terminalThemeOverride ??
        terminalTheme.effectiveActiveDefaultTheme;

    useEffect(() {
      // TODO: listen for onTitleChange and update tab title
      terminalController.value = TerminalController(
        theme: getEffectiveTerminalTheme().toTerminalTheme(),
        typography: getEffectiveTerminalTypography(),
        debugLogging: kDebugMode,
        onResize: (rows, cols) {
          sshSession?.resizeTerminal(cols, rows);
          // TODO: resize overlay
        },
      );
      return () => terminalController.value?.dispose();
    }, []);

    useEffect(() {
      if (terminalController.value == null) return null;
      terminalController.value!.typography = getEffectiveTerminalTypography();
      terminalController.value!.theme = getEffectiveTerminalTheme()
          .toTerminalTheme();
      return null;
    }, [terminalTypography.value, terminalTheme]);

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

        _terminalController.fitResize(size);
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

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(widget.session.connection.id);
      if (connectionFull != null) openSsh(connectionFull);
      return () => widget.session.dispose();
    }, []);

    if (widget.session.isConnected) {
      return SizedBox.expand(
        child: Container(
          color: getEffectiveTerminalTheme().backgroundColor,
          padding: const .all(8),
          child: TerminalView(controller: _terminalController),
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
                sizes: {.sm: 12, .md: 8},
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
}
