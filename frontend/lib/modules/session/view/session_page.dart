import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_term/cliq_term.dart';

import '../../../shared/ui/navigation_shell.dart';
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final terminalController = useState<TerminalController?>(null);
    final typography = context.theme.typography;
    final size = MediaQuery.of(context).size;

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final themes = ref.watch(terminalThemeProvider);

    getEffectiveTerminalTypography() =>
        widget.session.connection.terminalTypographyOverride ??
        defaultTerminalTypography.value;

    getEffectiveTerminalTheme() =>
        widget.session.connection.terminalThemeOverride ??
        themes.findById(defaultTerminalTheme.value)!;

    buildTerminalController() {
      // TODO: listen for onTitleChange and update tab title
      return TerminalController(
        theme: getEffectiveTerminalTheme().toTerminalTheme(),
        typography: getEffectiveTerminalTypography(),
        debugLogging: kDebugMode,
        onResize: (rows, cols) {
          sshSession?.resizeTerminal(cols, rows);
          // TODO: resize overlay
        },
      );
    }

    closeSession() {
      ref
          .read(sessionProvider.notifier)
          .closeAnyMaybeGo(NavigationShell.of(context), widget.session.id);
    }

    retrySession({bool skipHostKeyVerification = false}) {
      ref
          .read(sessionProvider.notifier)
          .resetSession(
            NavigationShell.of(context),
            session.id,
            skipHostKeyVerification: skipHostKeyVerification,
          );
      terminalController.value = buildTerminalController();
    }

    // initial setup of terminal controller
    useEffect(() {
      terminalController.value = buildTerminalController();
      return () => terminalController.value?.dispose();
    }, []);

    // open SSH connection when terminal controller is set
    useEffect(() {
      if (terminalController.value == null) return null;

      Future<void> openSsh(ConnectionFull connection) async {
        final client = await ref
            .read(sessionProvider.notifier)
            .createSSHClient(widget.session, connection);

        final shell = await ref
            .read(sessionProvider.notifier)
            .spawnShell(widget.session.id, client);

        terminalController.value!.fitResize(size);
        terminalController.value!.onInput = (s) {
          if (sshSession != null) {
            sshSession!.stdin.add(Uint8List.fromList(s.codeUnits));
          }
        };

        shell?.stdout.listen((data) {
          terminalController.value!.feed(String.fromCharCodes(data));
        });

        shell?.stderr.listen((data) {
          terminalController.value!.feed(String.fromCharCodes(data));
        });
      }

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(widget.session.connection.id);
      if (connectionFull != null) openSsh(connectionFull);
      return () => widget.session.dispose();
    }, [terminalController.value]);

    // update terminal controller when typography or theme changes
    useEffect(() {
      if (terminalController.value == null) return null;
      terminalController.value!.setTerminalTypography(getEffectiveTerminalTypography());
      terminalController.value!.setTerminalTheme(getEffectiveTerminalTheme().toTerminalTheme());
      return null;
    }, [defaultTerminalTypography.value, defaultTerminalTheme.value]);

    buildConnecting() {
      return [
        FCircularProgress(),
        const SizedBox(height: 8),
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

    buildKnownHostWarning() {
      return [
        Icon(LucideIcons.fingerprintPattern, size: 48),
        const SizedBox(height: 8),
        Text.rich(
          textAlign: .center,
          TextSpan(
            children: [
              session.knownHostError!.knownHost != null
                  ? TextSpan(text: 'Update fingerprint for ')
                  : TextSpan(text: 'Accept fingerprint for '),
              TextSpan(
                text: session.knownHostError!.host,
                style: typography.xl.copyWith(fontWeight: .bold),
              ),
              TextSpan(text: '?'),
            ],
          ),
          style: typography.xl,
        ),
        if (session.knownHostError!.knownHost != null)
          Text(
            'The host is known, but the saved fingerprint does not match.',
            style: typography.base.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
            textAlign: .center,
          ),
        const SizedBox(height: 32),
        FCard(
          subtitle: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('${session.knownHostError!.algorithm} (SHA256)'),
              FTooltip(
                tipBuilder: (_, _) => Text('Click to copy'),
                child: FButton.icon(
                  onPress: () => Commons.copyToClipboard(
                    context,
                    session.knownHostError!.sha256Fingerprint,
                  ),
                  child: Icon(LucideIcons.copy, size: 14),
                ),
              ),
            ],
          ),
          child: SelectableText(session.knownHostError!.sha256Fingerprint),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            FButton(
              variant: .outline,
              onPress: closeSession,
              child: Text('Close'),
            ),
            const Spacer(),
            FButton(
              variant: .outline,
              onPress: () => retrySession(skipHostKeyVerification: true),
              child: Text('Accept'),
            ),
            FButton(
              onPress: () async {
                await ref
                    .read(sessionProvider.notifier)
                    .acceptFingerprint(session.id, session.knownHostError!);
                retrySession();
              },
              child: Text('Save & Accept'),
            ),
          ],
        ),
      ];
    }

    buildError() {
      return [
        Icon(LucideIcons.plugZap, size: 48),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Failed to connect to '),
              TextSpan(
                text: '${session.connection.addressAndPort}:',
                style: typography.xl.copyWith(fontWeight: .bold),
              ),
            ],
          ),
          style: typography.xl,
        ),
        const SizedBox(height: 32),
        if (session.connectionError != null)
          FCard(
            subtitle: Text(
              session.connectionError!,
              style: typography.base,
              textAlign: TextAlign.center,
            ),
          ),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            FButton(
              variant: .outline,
              onPress: closeSession,
              child: Text('Close'),
            ),
            FButton(onPress: retrySession, child: Text('Retry')),
          ],
        ),
      ];
    }

    if (widget.session.isConnected && terminalController.value != null) {
      return SizedBox.expand(
        child: Container(
          color: getEffectiveTerminalTheme().backgroundColor,
          padding: const .all(8),
          child: TerminalView(controller: terminalController.value!),
        ),
      );
    }

    return CliqGridContainer(
      alignment: .center,
      children: [
        CliqGridRow(
          children: [
            CliqGridColumn(
              child: Column(
                children: [
                  if (session.knownHostError != null)
                    ...buildKnownHostWarning()
                  else if (session.connectionError != null)
                    ...buildError()
                  else if (session.isLikelyLoading)
                    ...buildConnecting(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
