import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/model/keyboard_shortcuts.model.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cliq_term/cliq_term.dart';

import '../../../shared/ui/navigation_shell.dart';
import '../provider/session.provider.dart';
import 'generic_session_page.dart';

/// The padding around the terminal view in the session page.
const kShellSessionPagePadding = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 4,
);
const kAccessoryBarHeight = 48.0;

class SshSessionPage extends StatefulHookConsumerWidget {
  final String sessionId;
  final FocusNode? focusNode;

  const SshSessionPage({super.key, required this.sessionId, this.focusNode});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SshSessionPageState();
}

class _SshSessionPageState extends ConsumerState<SshSessionPage>
    with AutomaticKeepAliveClientMixin {
  OverlayEntry? _accessoryBarEntry;

  @override
  bool get wantKeepAlive => true;

  void _showAccessoryBar() {
    _accessoryBarEntry?.remove();
    _accessoryBarEntry = OverlayEntry(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        final keyboardVisible = viewInsets > 0;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          left: 0,
          right: 0,
          bottom: keyboardVisible ? viewInsets : -kAccessoryBarHeight,
          height: kAccessoryBarHeight,
          child: Container(color: Colors.red),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_accessoryBarEntry!);
  }

  @override
  void dispose() {
    _accessoryBarEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
    final sshScrollbackSize = useStore(.sshScrollbackSize);

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
        maxScrollbackLines: sshScrollbackSize.value,
        onResize: (rows, cols) {
          session.sshSession?.resizeTerminal(cols, rows);
          // TODO: resize overlay
        },
      );
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
        if (PlatformUtils.isMobile) {
          _showAccessoryBar();
        }
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

      Future<void> openSsh(ConnectionFull connection) async {
        if (terminalController.value == null) return;

        final client =
            session.client ??
            await ref
                .read(sessionProvider.notifier)
                .createSSHClient(session, connection);

        if (client == null || !mounted) {
          return;
        }

        final sshSession = await ref
            .read(sessionProvider.notifier)
            .spawnSsh(session.id, client, terminalController.value!);

        // close SSH session when terminal is closed
        sshSession?.done.then((_) {
          if (!context.mounted) return;
          ref
              .read(sessionProvider.notifier)
              .closeSessionAndMaybeGo(NavigationShell.of(context), session.id);
        });

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

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(session.connection.id);

      if (connectionFull != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          openSsh(connectionFull);
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

    return GenericSessionPage(
      session: session,
      isConnected: session.isConnected && terminalController.value != null,
      isLikelyLoading: session.isLikelyLoading,
      onRetry: retrySession,
      child: SizedBox.expand(
        child: Container(
          color: effectiveTerminalTheme.backgroundColor,
          padding: kShellSessionPagePadding.copyWith(
            bottom:
                kShellSessionPagePadding.bottom +
                MediaQuery.of(context).viewInsets.bottom +
                kAccessoryBarHeight,
          ),
          child: TerminalView(
            controller: terminalController.value!,
            focusNode: widget.focusNode,
            copyShortcut: shortcuts.value.shortcuts[KeyboardShortcutType.copy],
            pasteShortcut:
                shortcuts.value.shortcuts[KeyboardShortcutType.paste],
          ),
        ),
      ),
    );
  }
}
