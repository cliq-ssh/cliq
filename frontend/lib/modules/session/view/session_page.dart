import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/model/keyboard_shortcuts.model.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow, CliqFontFamily;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cliq_term/cliq_term.dart';

import '../../../shared/ui/navigation_shell.dart';
import '../provider/session.provider.dart';

/// The padding around the terminal view in the session page.
const kShellSessionPagePadding = 8.0;

class SessionPage extends StatefulHookConsumerWidget {
  final String sessionId;
  final FocusNode? focusNode;

  const SessionPage({super.key, required this.sessionId, this.focusNode});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShellSessionPageState();
}

class _ShellSessionPageState extends ConsumerState<SessionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final typography = context.theme.typography;
    final size = MediaQuery.of(context).size;

    final session = ref
        .watch(sessionProvider.notifier)
        .getSessionById(widget.sessionId)!;

    final terminalController = useState<TerminalController?>(
      session.terminalController,
    );

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final themes = ref.watch(terminalThemeProvider);

    final shortcuts = useStore(.shortcuts);

    final effectiveTerminalTheme = session.connection.getEffectiveTerminalTheme(
      themes,
      defaultTerminalTheme.value,
    );

    getEffectiveTerminalTypography() =>
        session.connection.terminalTypographyOverride ??
        defaultTerminalTypography.value;

    buildTerminalController() {
      // TODO: listen for onTitleChange and update tab title
      return TerminalController(
        theme: effectiveTerminalTheme.toTerminalTheme(),
        typography: getEffectiveTerminalTypography(),
        debugLogging: kDebugMode,
        onResize: (rows, cols) {
          session.sshSession?.resizeTerminal(cols, rows);
          // TODO: resize overlay
        },
      );
    }

    closeSession() {
      ref
          .read(sessionProvider.notifier)
          .closeSessionAndMaybeGo(NavigationShell.of(context), session.id);
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

    // focus terminal when page is opened
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode?.requestFocus();
      });
      return null;
    }, []);

    // initial setup of terminal controller
    useEffect(() {
      if (terminalController.value != null) return null;
      terminalController.value = buildTerminalController();
      return null;
    }, []);

    // open SSH connection when terminal controller is set
    useEffect(() {
      if (terminalController.value == null) return null;

      Future<void> openSession(
        ConnectionFull connection, {
        bool isSftp = false,
      }) async {
        if (terminalController.value == null) return;

        final client =
            session.client ??
            await ref
                .read(sessionProvider.notifier)
                .createSSHClient(session, connection);

        if (client == null || !mounted) {
          return;
        }

        if (session.type == .ssh) {
          final sshSession = await ref
              .read(sessionProvider.notifier)
              .spawnSsh(session.id, client, terminalController.value!);

          terminalController.value!.fitResize(size);

          // close SSH session when terminal is closed
          sshSession?.done.then((_) {
            if (!mounted) return;
            closeSession();
          });

          terminalController.value!.fitResize(size);

          terminalController.value!.onInput = (s) {
            sshSession?.stdin.add(Uint8List.fromList(s.codeUnits));
          };

          StreamSubscription? stdoutSub =
              session.stdoutSub ??
              sshSession?.stdout.listen((data) {
                final controller = terminalController.value;
                if (controller != null) {
                  controller.feed(String.fromCharCodes(data));
                }
              });

          StreamSubscription? stderrSub =
              session.stderrSub ??
              sshSession?.stderr.listen((data) {
                final controller = terminalController.value;
                if (controller != null) {
                  controller.feed(String.fromCharCodes(data));
                }
              });

          ref
              .read(sessionProvider.notifier)
              .setStreamListeners(session.id, stdoutSub, stderrSub);
        }
        if (session.type == .sftp) {
          await ref
              .read(sessionProvider.notifier)
              .spawnSftp(session.id, client);
        }
      }

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(session.connection.id);

      if (connectionFull != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          openSession(connectionFull);
        });
      }

      return null;
    }, [terminalController.value]);

    // update terminal controller when typography or theme changes
    useEffect(() {
      if (terminalController.value == null) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        terminalController.value!.setTerminalTypography(
          getEffectiveTerminalTypography(),
        );
        terminalController.value!.setTerminalTheme(
          effectiveTerminalTheme.toTerminalTheme(),
        );
      });

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
                text: session.connection.address,
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
            style: typography.md.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
            textAlign: .center,
          ),
        const SizedBox(height: 16),
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
                    .acceptFingerprint(
                      session.connection.vaultId,
                      session.id,
                      session.knownHostError!,
                    );
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
                text: session.connection.addressAndPort,
                style: typography.xl.copyWith(fontWeight: .bold),
              ),
            ],
          ),
          style: typography.xl,
        ),
        const SizedBox(height: 16),
        if (session.connectionError != null)
          FCard(
            style: .delta(
              decoration: .boxDelta(
                color: context.theme.colors.destructive.withValues(alpha: 0.1),
                border: Border.all(
                  color: context.theme.colors.destructive.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
            ),
            child: Text(
              session.connectionError!,
              style: context.theme.typography.xs.copyWith(
                fontFamily: CliqFontFamily.secondary.fontFamily,
              ),
            ),
          ),
        const SizedBox(height: 8),
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

    if (session.isConnected && terminalController.value != null) {
      if (session.type == .sftp) {
        // TODO:
        return Text('TODO: Implement SFTP View');
      }

      return SizedBox.expand(
        child: Container(
          color: effectiveTerminalTheme.backgroundColor,
          padding: const .all(kShellSessionPagePadding),
          child: TerminalView(
            controller: terminalController.value!,
            focusNode: widget.focusNode,
            copyShortcut: shortcuts.value.shortcuts[KeyboardShortcutType.copy],
            pasteShortcut:
                shortcuts.value.shortcuts[KeyboardShortcutType.paste],
          ),
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
